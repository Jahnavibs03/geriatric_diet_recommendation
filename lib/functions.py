import pandas as pd
import numpy as np
import re
import random
import google.generativeai as genai

from sklearn.linear_model import Ridge
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

# Function to standardize vitamin names
def convert_vitamin(inp):
    vitamin_map = {
        "vita": "Vitamin_A",
        "vitc": "Vitamin_C",
        "vitd": "Vitamin_D",
        "vite": "Vitamin_E",
        "vitk": "Vitamin_K"
    }
    if re.match(r"vitb[1-9]", inp):
        inp = re.sub(r"vitb[1-9]", "Vitamin_B", inp)
    for key, value in vitamin_map.items():
        if inp.startswith(key):
            return inp.replace(key, value, 1)
    return inp

# Prediction logic
def predict_nutrient_impact_ridge(df, bmi, bdi, bai, gender):
    X = df[["Gender", "BAI", "BDI", "BMI"]]
    y = df.drop(columns=["Gender", "BAI", "BDI", "BMI", "total_nutrition_score", "energy_kj"])

    predicted_nutrients = {}
    user_input = np.array([[gender, bai, bdi, bmi]])

    for nutrient in y.columns:
        ridge_model = Ridge(alpha=1.0)
        ridge_model.fit(X, y[nutrient])
        predicted_nutrients[nutrient] = ridge_model.predict(user_input)[0]

    predicted_nutrients_df = pd.DataFrame(
        list(predicted_nutrients.items()), columns=["Nutrient", "Predicted Value"]
    ).sort_values(by="Predicted Value", ascending=False)

    most_impacted_df = predicted_nutrients_df.head(15)
    least_impacted_df = predicted_nutrients_df.tail(5)

    # Select a random most impacted nutrient
    inp = most_impacted_df.iloc[random.randint(0, 14), 0]
    inp = inp.split('_')[0]
    inp = convert_vitamin(inp)

    return inp

# Load dataset
file_path = "C:\Users\Jahnavi\geriatric_app\lib\final_cleaned_dataset.csv"
df = pd.read_csv(file_path)

# User input
gender_options = {"0": "Female", "1": "Male"}
gender = input("Enter Gender (0 for Female, 1 for Male): ")
while gender not in gender_options:
    print("Invalid input. Please enter 0 for Female or 1 for Male.")
    gender = input("Enter Gender (0 for Female, 1 for Male): ")
gender = int(gender)

BAI = float(input("Enter BAI score: "))
BDI = float(input("Enter BDI score: "))
BMI = float(input("Enter BMI: "))
age = int(input("Enter age: "))

# Get most impacted nutrient
most_impacted = predict_nutrient_impact_ridge(df, BMI, BDI, BAI, gender)
print("Most impacted nutrient:", most_impacted)

# Set up Google Gemini
genai.configure(api_key="AIzaSyAww9CSdldx6Ocq1y2z1Xf0JqMgYbR6CCA")  # Replace with your API key

model = genai.GenerativeModel("gemini-1.5-flash")

response = model.generate_content(
    f"Give an Indian diet recommendation for a deficiency in {most_impacted}, focused on geriatric mental health. "
    f"The person has a BMI of {BMI}, BDI score of {BDI}, BAI score of {BAI}, and is aged {age}."
)

print("\nRecommended Diet Plan:\n")
print(response.text)
