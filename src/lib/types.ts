



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
