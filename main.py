from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import numpy as np
import os
import requests
from dotenv import load_dotenv
from sklearn.linear_model import Ridge
import re

load_dotenv()

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace "*" with frontend URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "API is running!"}

class ScoreInput(BaseModel):
    bai_score: float
    bdi_score: float
    height: float  # in cm
    weight: float  # in kg
    gender: int    # 0 or 1
    age: int

# Load dataset and train model once at startup
try:
    df = pd.read_csv("final_cleaned_dataset.csv")
    features = ["Gender", "BAI", "BDI", "BMI"]
    for col in features:
        if col not in df.columns:
            raise ValueError(f"Expected column '{col}' in dataset")
    X = df[features]
    target_cols = [col for col in df.columns if col not in features]
    if not target_cols:
        raise ValueError("No target columns found in dataset for nutrient predictions")
    y = df[target_cols]
    model = Ridge()
    model.fit(X, y)
except Exception as e:
    raise RuntimeError(f"Failed to load dataset or train model: {e}")

@app.post("/recommend_diet")
async def recommend_diet(data: ScoreInput):
    try:
        # Calculate BMI
        height_m = data.height / 100
        bmi = data.weight / (height_m ** 2)

        # Prepare input array for prediction
        input_data = np.array([[data.gender, data.bai_score, data.bdi_score, bmi]])
        pred = model.predict(input_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")

    try:
        pred_values = pred[0]

        # Select top 5 nutrients by predicted score
        top_n = 5
        top_indices = np.argsort(pred_values)[-top_n:][::-1]  # descending order

        # Get nutrient names and their predicted scores
        top_nutrients = [(target_cols[i], pred_values[i]) for i in top_indices]

        # Prepare weights for weighted random sampling
        scores = np.array([score for _, score in top_nutrients])

        # Shift scores to positive to avoid issues with negative values and normalize
        min_score = scores.min()
        if min_score < 0:
            scores = scores - min_score + 1e-3
        else:
            scores = scores + 1e-3

        weights = scores / scores.sum()

        # Randomly choose one nutrient weighted by predicted scores
        chosen_nutrient = np.random.choice([nutr for nutr, _ in top_nutrients], p=weights)

        # Map short nutrient name to full name (e.g., vitA -> Vitamin_A)
        nutrient_short_lower = chosen_nutrient.lower()
        if nutrient_short_lower.startswith("vit") and len(nutrient_short_lower) > 3:
            letter = nutrient_short_lower[3].upper()
            nutrient_full = f"Vitamin_{letter}"
        else:
            nutrient_full = chosen_nutrient

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Identifying nutrient deficiency failed: {e}")

    # Gemini prompt with capitalized names and computed BMI
    prompt = (
        f"Provide a personalized Indian diet recommendation for a {nutrient_full} deficiency in an elderly patient "
        f"with the following details: Age {data.age}, BMI {bmi:.2f}, BDI score {data.bdi_score}, and BAI score {data.bai_score}. "
        f"Focus on improving geriatric mental health and addressing the deficiency of {nutrient_full}."
    )

    api_key = os.getenv("GEMINI_API_KEY")
    # if not api_key:
    #     raise HTTPException(status_code=500, detail="Gemini API key not configured")

    try:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
        headers = {"Content-Type": "application/json"}
        data_gemini = {"contents": [{"parts": [{"text": prompt}]}]}

        response = requests.post(url, headers=headers, json=data_gemini)
        response.raise_for_status()
        result = response.json()

        recommendation = "IMPACTED/ DEFICIENT NUTRIENT: " + nutrient_full + "\n"
        candidates = result.get("candidates", [])
        if candidates:
            parts = candidates[0].get("content", {}).get("parts", [])
            for part in parts:
                recommendation += part.get("text", "")
        else:
            recommendation = "No recommendation generated from Gemini."

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gemini API call failed: {e}")

    # Clean recommendation text
    recommendation = re.sub(r"[*#]", "", recommendation)
    recommendation = recommendation.strip()
    recommendation = re.sub(r'\n{3,}', '\n\n', recommendation)

    return {"recommendation": recommendation}
