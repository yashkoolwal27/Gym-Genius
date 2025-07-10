

import { z } from 'zod';


export interface StoredPlan {
    id: string;
    generatedPlan: string;
    createdAt: string;
}

export type WorkoutPlan = StoredPlan;
export type MealPlan = StoredPlan;

export interface WorkoutSet {
  id: string;
  reps: string;
  weight: string;
}

export interface LoggedExercise {
  id: string;
  name: string;
  sets: WorkoutSet[];
}

export interface WorkoutLog {
  id: string;
  date: string;
  time: string;
  exerciseTypes: string[];
  exercises: LoggedExercise[];
  createdAt: string;
}

export interface DietLog {
  id: string;
  date: string;
  meals: {
    breakfast: string;
    lunch: string;
    dinner: string;
    snacks: string;
  };
  createdAt: string;
}

export interface MealLog {
    id: string;
    createdAt: string;
    date: string;
    mealType: string;
    macronutrients: string;
    fitnessGoals: string;
    foodCategory: string;
    mealDetails: string;
}

export interface WeightLog {
    id: string;
    date: string;
    weight: number;
}

export interface Exercise {
  name: string;
  image: string;
  hint: string;
}

export interface SubCategory {
  name: string;
  exercises: readonly Exercise[] | SubCategoryData;
}

export interface SubCategoryData {
    subCategories: readonly SubCategory[];
}

export type CategoryData = readonly Exercise[] | SubCategoryData;

// Schemas for AI Trainer Flow
const WorkoutSetSchema = z.object({
  id: z.string(),
  reps: z.string(),
  weight: z.string(),
});

const LoggedExerciseSchema = z.object({
  id: z.string(),
  name: z.string(),
  sets: z.array(WorkoutSetSchema),
});

const WorkoutLogSchema = z.object({
  id: z.string(),
  date: z.string(),
  time: z.string(),
  exerciseTypes: z.array(z.string()),
  exercises: z.array(LoggedExerciseSchema),
  createdAt: z.string(),
});

const MealLogSchema = z.object({
    id: z.string(),
    createdAt: z.string(),
    date: z.string(),
    mealType: z.string(),
    macronutrients: z.string(),
    fitnessGoals: z.string(),
    foodCategory: z.string(),
    mealDetails: z.string(),
});

const WeightLogSchema = z.object({
    id: z.string(),
    date: z.string(),
    weight: z.number(),
});

export const GetAITrainerFeedbackInputSchema = z.object({
  workoutLogs: z.array(WorkoutLogSchema).describe("The user's logged workouts."),
  mealLogs: z.array(MealLogSchema).describe("The user's logged meals."),
  weightLogs: z.array(WeightLogSchema).describe("The user's logged weights over time."),
});
export type GetAITrainerFeedbackInput = z.infer<typeof GetAITrainerFeedbackInputSchema>;

export const GetAITrainerFeedbackOutputSchema = z.object({
  feedback: z.string().describe('The generated feedback and advice for the user in Markdown format. Use ### for main section titles and ** for sub-headings.'),
});
export type GetAITrainerFeedbackOutput = z.infer<typeof GetAITrainerFeedbackOutputSchema>;
