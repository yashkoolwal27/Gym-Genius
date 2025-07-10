
import type { FoodItem } from "./types";

export const foodData = {
    "Fruits": [
        { name: "Apple", image: "https://placehold.co/200x200.png", hint: "red apple", calories: 95, protein: 0.5 },
        { name: "Banana", image: "https://placehold.co/200x200.png", hint: "yellow banana", calories: 105, protein: 1.3 },
        { name: "Strawberry", image: "https://placehold.co/200x200.png", hint: "red strawberry", calories: 32, protein: 0.7 },
        { name: "Blueberry", image: "https://placehold.co/200x200.png", hint: "fresh blueberry", calories: 57, protein: 0.7 },
        { name: "Tomato", image: "https://placehold.co/200x200.png", hint: "red tomato", calories: 18, protein: 0.9 },
        { name: "Avocado", image: "https://placehold.co/200x200.png", hint: "green avocado", calories: 160, protein: 2.0 },
        { name: "Orange", image: "https://placehold.co/200x200.png", hint: "fresh orange", calories: 47, protein: 0.9 },
        { name: "Grapes", image: "https://placehold.co/200x200.png", hint: "purple grapes", calories: 69, protein: 0.7 },
        { name: "Watermelon", image: "https://placehold.co/200x200.png", hint: "watermelon slice", calories: 30, protein: 0.6 },
        { name: "Pineapple", image: "https://placehold.co/200x200.png", hint: "pineapple slice", calories: 50, protein: 0.5 },
        { name: "Mango", image: "https://placehold.co/200x200.png", hint: "yellow mango", calories: 60, protein: 0.8 },
        { name: "Kiwi", image: "https://placehold.co/200x200.png", hint: "kiwi slice", calories: 61, protein: 1.1 },
        { name: "Peach", image: "https://placehold.co/200x200.png", hint: "peach fruit", calories: 59, protein: 1.4 },
    ],
    "Dairy & Eggs": [],
    "Grains & Pulses": [],
    "Meat & Seafood": [],
    "Bakery & Sweets": [],
    "Beverages": [],
    "Spices & Oils": [],
    "Munchies": [],
} as const;

export type FoodCategory = keyof typeof foodData;
