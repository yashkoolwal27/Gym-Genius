"use server";

import { z } from "zod";
import { generateWorkoutPlan, GenerateWorkoutPlanInput, GenerateWorkoutPlanOutput } from "@/ai/flows/generate-workout-plan";
import { generateMealPlan, GenerateMealPlanInput, GenerateMealPlanOutput } from "@/ai/flows/generate-meal-plan";

const workoutSchema = z.object({
  fitnessLevel: z.enum(['Beginner', 'Intermediate', 'Advanced']),
  goals: z.string().min(3, "Goals must be at least 3 characters."),
  availableEquipment: z.string().min(3, "Please list available equipment."),
  workoutDays: z.coerce.number().min(1).max(7),
  workoutType: z.string().min(3, "Workout type must be at least 3 characters."),
});

const mealSchema = z.object({
    dietaryRestrictions: z.string().min(3, "Please describe any dietary restrictions."),
    preferences: z.string().min(3, "Please list your food preferences."),
    fitnessGoals: z.string().min(3, "Please describe your fitness goals."),
    numberOfMeals: z.coerce.number().min(1).max(5),
});


export async function getWorkoutPlan(values: z.infer<typeof workoutSchema>): Promise<{ success: boolean; data: GenerateWorkoutPlanOutput | null; error: string | null }> {
    const validatedFields = workoutSchema.safeParse(values);

    if (!validatedFields.success) {
        return { success: false, data: null, error: "Invalid input." };
    }

    try {
        const result = await generateWorkoutPlan(validatedFields.data as GenerateWorkoutPlanInput);
        return { success: true, data: result, error: null };
    } catch (error) {
        console.error("Error generating workout plan:", error);
        return { success: false, data: null, error: "Failed to generate workout plan. Please try again." };
    }
}

export async function getMealPlan(values: z.infer<typeof mealSchema>): Promise<{ success: boolean; data: GenerateMealPlanOutput | null; error: string | null }> {
    const validatedFields = mealSchema.safeParse(values);

    if (!validatedFields.success) {
        return { success: false, data: null, error: "Invalid input." };
    }

    try {
        const result = await generateMealPlan(validatedFields.data as GenerateMealPlanInput);
        return { success: true, data: result, error: null };
    } catch (error) {
        console.error("Error generating meal plan:", error);
        return { success: false, data: null, error: "Failed to generate meal plan. Please try again." };
    }
}
