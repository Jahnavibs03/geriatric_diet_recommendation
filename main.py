from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import numpy as np
import os
import requests
import re
from dotenv import load_dotenv
from sklearn.linear_model import Ridge
from fastapi.middleware.cors import CORSMiddleware

# Load environment variables
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

app = FastAPI()

# Enable CORS for frontend communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
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

# Load model and dataset once at startup
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
        # Compute BMI
        height_m = data.height / 100
        bmi = data.weight / (height_m ** 2)
        input_data = np.array([[data.gender, data.bai_score, data.bdi_score, bmi]])
        pred = model.predict(input_data)
        pred_values = pred[0]

        # Get top N nutrients based on predicted need
        top_n = 10
        top_indices = np.argsort(pred_values)[-top_n:][::-1]  # descending order

        # Filter out 'ufa_mg' if it's dominating
        filtered_indices = [i for i in top_indices if target_cols[i] != "ufa_mg"]
        if not filtered_indices:
            filtered_indices = top_indices  # fallback

        # Extract scores and apply temperature sampling
        temperature = 1.5
        top_nutrients = [(target_cols[i], pred_values[i]) for i in filtered_indices]
        scores = np.array([score for _, score in top_nutrients])
        scores = scores - scores.min() + 1e-3  # make positive
        adjusted_scores = scores ** (1 / temperature)
        weights = adjusted_scores / adjusted_scores.sum()

        # Randomly select a nutrient
        chosen_nutrient = np.random.choice(
            [nutr for nutr, _ in top_nutrients], p=weights
        )

        # Convert short name to full name if needed
        lower_name = chosen_nutrient.lower()
        if lower_name.startswith("vit") and len(lower_name) > 3:
            letter = lower_name[3].upper()
            nutrient_full = f"Vitamin_{letter}"
        else:
            nutrient_full = chosen_nutrient

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Nutrient selection failed: {e}")

    # Prepare Gemini prompt
    prompt = (
        f"Provide a personalized Indian diet recommendation for a {nutrient_full} deficiency "
        f"in an elderly patient with the following details: Age {data.age}, "
        f"BMI {bmi:.2f}, BDI score {data.bdi_score}, and BAI score {data.bai_score}. "
        f"Focus on improving geriatric mental health and addressing the deficiency of {nutrient_full}."
    )

    try:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
        headers = {"Content-Type": "application/json"}
        data_gemini = {"contents": [{"parts": [{"text": prompt}]}]}

        response = requests.post(url, headers=headers, json=data_gemini)
        response.raise_for_status()
        result = response.json()

        recommendation = f"IMPACTED / DEFICIENT NUTRIENT: {nutrient_full}\n"
        candidates = result.get("candidates", [])
        if candidates:
            parts = candidates[0].get("content", {}).get("parts", [])
            for part in parts:
                recommendation += part.get("text", "")
        else:
            recommendation = "No recommendation generated from Gemini."

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gemini API call failed: {e}")

    # Clean recommendation output
    recommendation = re.sub(r"[*#]", "", recommendation)
    recommendation = recommendation.strip()
    recommendation = re.sub(r'\n{3,}', '\n\n', recommendation)

    return {"recommendation": recommendation}
