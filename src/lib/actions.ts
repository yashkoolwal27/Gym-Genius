
"use server";

import { generateMealPlan, generateMealPlanFromHistory, type GenerateMealPlanInput, type GenerateMealPlanFromHistoryInput } from "@/ai/flows/generate-meal-plan";
import { generateWorkoutPlan, type GenerateWorkoutPlanInput } from "@/ai/flows/generate-workout-plan";
import { getAITrainerFeedback, type GetAITrainerFeedbackInput } from "@/ai/flows/get-ai-trainer-feedback";

async function handleAction<T>(action: Promise<T>): Promise<{ success: true; data: T; } | { success: false; error: string; }> {
  try {
    const data = await action;
    return { success: true, data };
  } catch (error) {
    console.error("Action failed:", error);
    return { success: false, error: error instanceof Error ? error.message : "An unknown error occurred." };
  }
}

export async function getMealPlan(values: GenerateMealPlanInput) {
    return handleAction(generateMealPlan(values));
}

export async function getMealPlanFromHistory(values: GenerateMealPlanFromHistoryInput) {
    return handleAction(generateMealPlanFromHistory(values));
}

export async function getWorkoutPlan(values: GenerateWorkoutPlanInput) {
    return handleAction(generateWorkoutPlan(values));
}

export async function getTrainerFeedback(values: GetAITrainerFeedbackInput) {
    return handleAction(getAITrainerFeedback(values));
}
