
import type { FoodItem } from "./types";

export const foodData = {
    "Fruits": [
        { name: "Apple", image: "https://placehold.co/200x200.png", hint: "red apple", calories: 95, protein: 0.5 },
        { name: "Banana", image: "https://placehold.co/200x200.png", hint: "yellow banana", calories: 105, protein: 1.3 },
        { name: "Strawberry", image: "https://placehold.co/200x200.png", hint: "red strawberry", calories: 32, protein: 0.7 },
        { name: "Blueberry", image: "https://placehold.co/200x200.png", hint: "fresh blueberry", calories: 57, protein: 0.7 },
        { name: "Orange", image: "https://placehold.co/200x200.png", hint: "fresh orange", calories: 47, protein: 0.9 },
        { name: "Grapes", image: "https://placehold.co/200x200.png", hint: "purple grapes", calories: 69, protein: 0.7 },
        { name: "Watermelon", image: "https://placehold.co/200x200.png", hint: "watermelon slice", calories: 30, protein: 0.6 },
        { name: "Pineapple", image: "https://placehold.co/200x200.png", hint: "pineapple slice", calories: 50, protein: 0.5 },
        { name: "Mango", image: "https://placehold.co/200x200.png", hint: "yellow mango", calories: 60, protein: 0.8 },
        { name: "Kiwi", image: "https://placehold.co/200x200.png", hint: "kiwi slice", calories: 61, protein: 1.1 },
        { name: "Peach", image: "https://placehold.co/200x200.png", hint: "peach fruit", calories: 59, protein: 1.4 },
    ],
    "Dairy & Eggs": [
        { name: "Milk", image: "https://placehold.co/200x200.png", hint: "glass milk", calories: 103, protein: 8 },
        { name: "Cheese (Cheddar)", image: "https://placehold.co/200x200.png", hint: "cheddar cheese", calories: 113, protein: 7 },
        { name: "Yogurt (Greek)", image: "https://placehold.co/200x200.png", hint: "greek yogurt", calories: 100, protein: 17 },
        { name: "Egg", image: "https://placehold.co/200x200.png", hint: "fried egg", calories: 78, protein: 6 },
        { name: "Cottage Cheese", image: "https://placehold.co/200x200.png", hint: "cottage cheese", calories: 98, protein: 11 },
        { name: "Butter", image: "https://placehold.co/200x200.png", hint: "stick butter", calories: 102, protein: 0.1 },
    ],
    "Grains & Pulses": [
        { name: "White Rice", image: "https://placehold.co/200x200.png", hint: "bowl rice", calories: 205, protein: 4.3 },
        { name: "Brown Rice", image: "https://placehold.co/200x200.png", hint: "brown rice", calories: 216, protein: 5 },
        { name: "Oats", image: "https://placehold.co/200x200.png", hint: "oatmeal bowl", calories: 154, protein: 6 },
        { name: "Whole Wheat Bread", image: "https://placehold.co/200x200.png", hint: "bread slice", calories: 81, protein: 4 },
        { name: "Quinoa", image: "https://placehold.co/200x200.png", hint: "quinoa bowl", calories: 222, protein: 8 },
        { name: "Lentils", image: "https://placehold.co/200x200.png", hint: "lentil soup", calories: 230, protein: 18 },
        { name: "Chickpeas", image: "https://placehold.co/200x200.png", hint: "chickpeas bowl", calories: 269, protein: 15 },
    ],
    "Meat & Seafood": [
        { name: "Chicken Breast", image: "https://placehold.co/200x200.png", hint: "grilled chicken", calories: 165, protein: 31 },
        { name: "Salmon", image: "https://placehold.co/200x200.png", hint: "salmon steak", calories: 206, protein: 22 },
        { name: "Beef (Steak)", image: "https://placehold.co/200x200.png", hint: "grilled steak", calories: 271, protein: 25 },
        { name: "Tuna (Canned)", image: "https://placehold.co/200x200.png", hint: "canned tuna", calories: 184, protein: 40 },
        { name: "Shrimp", image: "https://placehold.co/200x200.png", hint: "cooked shrimp", calories: 85, protein: 20 },
        { name: "Pork Chop", image: "https://placehold.co/200x200.png", hint: "pork chop", calories: 231, protein: 26 },
    ],
    "Bakery & Sweets": [
        { name: "Croissant", image: "https://placehold.co/200x200.png", hint: "fresh croissant", calories: 231, protein: 4.7 },
        { name: "Chocolate Cake", image: "https://placehold.co/200x200.png", hint: "cake slice", calories: 371, protein: 4.3 },
        { name: "Donut", image: "https://placehold.co/200x200.png", hint: "glazed donut", calories: 195, protein: 2.5 },
        { name: "Dark Chocolate", image: "https://placehold.co/200x200.png", hint: "dark chocolate", calories: 170, protein: 2.2 },
    ],
    "Beverages": [
        { name: "Water", image: "https://placehold.co/200x200.png", hint: "glass water", calories: 0, protein: 0 },
        { name: "Coffee (Black)", image: "https://placehold.co/200x200.png", hint: "black coffee", calories: 2, protein: 0.3 },
        { name: "Orange Juice", image: "https://placehold.co/200x200.png", hint: "orange juice", calories: 112, protein: 1.7 },
        { name: "Green Tea", image: "https://placehold.co/200x200.png", hint: "green tea", calories: 2, protein: 0.5 },
    ],
    "Spices & Oils": [
        { name: "Olive Oil", image: "https://placehold.co/200x200.png", hint: "olive oil", calories: 119, protein: 0 },
        { name: "Salt", image: "https://placehold.co/200x200.png", hint: "salt shaker", calories: 0, protein: 0 },
        { name: "Black Pepper", image: "https://placehold.co/200x200.png", hint: "black pepper", calories: 6, protein: 0.2 },
    ],
    "Munchies": [
        { name: "Almonds", image: "https://placehold.co/200x200.png", hint: "almonds bowl", calories: 164, protein: 6 },
        { name: "Potato Chips", image: "https://placehold.co/200x200.png", hint: "potato chips", calories: 160, protein: 2 },
        { name: "Popcorn", image: "https://placehold.co/200x200.png", hint: "popcorn bowl", calories: 93, protein: 3 },
    ],
    "Breakfast": [
        { name: "Scrambled Eggs", image: "https://placehold.co/200x200.png", hint: "scrambled eggs", calories: 143, protein: 13 },
        { name: "Oatmeal with Berries", image: "https://placehold.co/200x200.png", hint: "oatmeal berries", calories: 250, protein: 8 },
        { name: "Avocado Toast", image: "https://placehold.co/200x200.png", hint: "avocado toast", calories: 200, protein: 7 },
    ],
    "Lunch": [
        { name: "Grilled Chicken Salad", image: "https://placehold.co/200x200.png", hint: "chicken salad", calories: 350, protein: 40 },
        { name: "Tuna Sandwich", image: "https://placehold.co/200x200.png", hint: "tuna sandwich", calories: 400, protein: 25 },
        { name: "Quinoa Bowl with Veggies", image: "https://placehold.co/200x200.png", hint: "quinoa bowl veggies", calories: 450, protein: 15 },
    ],
    "Dinner": [
        { name: "Salmon with Asparagus", image: "https://placehold.co/200x200.png", hint: "salmon asparagus", calories: 400, protein: 40 },
        { name: "Steak with Sweet Potato", image: "https://placehold.co/200x200.png", hint: "steak sweet potato", calories: 550, protein: 50 },
        { name: "Lentil Soup", image: "https://placehold.co/200x200.png", hint: "lentil soup", calories: 300, protein: 20 },
    ],
    "Snacks": [
        { name: "Apple with Peanut Butter", image: "https://placehold.co/200x200.png", hint: "apple peanut butter", calories: 280, protein: 8 },
        { name: "Greek Yogurt", image: "https://placehold.co/200x200.png", hint: "greek yogurt bowl", calories: 150, protein: 20 },
        { name: "Protein Shake", image: "https://placehold.co/200x200.png", hint: "protein shake", calories: 200, protein: 25 },
    ],
    "High-Protein": [
        { name: "Chicken Breast", image: "https://placehold.co/200x200.png", hint: "grilled chicken", calories: 165, protein: 31 },
        { name: "Greek Yogurt", image: "https://placehold.co/200x200.png", hint: "greek yogurt", calories: 100, protein: 17 },
        { name: "Tuna (Canned)", image: "https://placehold.co/200x200.png", hint: "canned tuna", calories: 184, protein: 40 },
        { name: "Lentils", image: "https://placehold.co/200x200.png", hint: "lentil soup", calories: 230, protein: 18 },
        { name: "Egg", image: "https://placehold.co/200x200.png", hint: "fried egg", calories: 78, protein: 6 },
    ],
    "High-Carb": [
        { name: "White Rice", image: "https://placehold.co/200x200.png", hint: "bowl rice", calories: 205, protein: 4.3 },
        { name: "Oats", image: "https://placehold.co/200x200.png", hint: "oatmeal bowl", calories: 154, protein: 6 },
        { name: "Banana", image: "https://placehold.co/200x200.png", hint: "yellow banana", calories: 105, protein: 1.3 },
        { name: "Sweet Potato", image: "https://placehold.co/200x200.png", hint: "sweet potato", calories: 180, protein: 4 },
    ],
    "Low-Carb": [
        { name: "Avocado", image: "https://placehold.co/200x200.png", hint: "avocado slice", calories: 160, protein: 2 },
        { name: "Broccoli", image: "https://placehold.co/200x200.png", hint: "broccoli floret", calories: 55, protein: 3.7 },
        { name: "Spinach", image: "https://placehold.co/200x200.png", hint: "spinach leaves", calories: 23, protein: 2.9 },
        { name: "Salmon", image: "https://placehold.co/200x200.png", hint: "salmon steak", calories: 206, protein: 22 },
    ],
    "Healthy Fats": [
        { name: "Avocado", image: "https://placehold.co/200x200.png", hint: "avocado slice", calories: 160, protein: 2 },
        { name: "Almonds", image: "https://placehold.co/200x200.png", hint: "almonds bowl", calories: 164, protein: 6 },
        { name: "Olive Oil", image: "https://placehold.co/200x200.png", hint: "olive oil", calories: 119, protein: 0 },
        { name: "Salmon", image: "https://placehold.co/200x200.png", hint: "salmon steak", calories: 206, protein: 22 },
    ],
    "Muscle Gain": [
        { name: "Chicken Breast", image: "https://placehold.co/200x200.png", hint: "grilled chicken", calories: 165, protein: 31 },
        { name: "Beef (Steak)", image: "https://placehold.co/200x200.png", hint: "grilled steak", calories: 271, protein: 25 },
        { name: "Quinoa", image: "https://placehold.co/200x200.png", hint: "quinoa bowl", calories: 222, protein: 8 },
        { name: "Milk", image: "https://placehold.co/200x200.png", hint: "glass milk", calories: 103, protein: 8 },
    ],
    "Fat Loss": [
        { name: "Green Tea", image: "https://placehold.co/200x200.png", hint: "green tea", calories: 2, protein: 0.5 },
        { name: "Grapefruit", image: "https://placehold.co/200x200.png", hint: "grapefruit slice", calories: 52, protein: 1 },
        { name: "Chili Pepper", image: "https://placehold.co/200x200.png", hint: "chili pepper", calories: 40, protein: 1.9 },
        { name: "Leafy Greens", image: "https://placehold.co/200x200.png", hint: "leafy greens", calories: 23, protein: 2.9 },
    ],
    "Maintenance": [
        { name: "Mixed Nuts", image: "https://placehold.co/200x200.png", hint: "mixed nuts", calories: 170, protein: 5 },
        { name: "Whole Wheat Bread", image: "https://placehold.co/200x200.png", hint: "bread slice", calories: 81, protein: 4 },
        { name: "Lean Protein & Veggies", image: "https://placehold.co/200x200.png", hint: "protein veggies", calories: 400, protein: 40 },
    ]
} as const;

export type FoodCategory = keyof typeof foodData;

    

    