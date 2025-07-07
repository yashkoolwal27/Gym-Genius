
export interface StoredPlan {
    id: string;
    generatedPlan: string;
    createdAt: string;
}

export type WorkoutPlan = StoredPlan;
export type MealPlan = StoredPlan;
