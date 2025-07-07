export interface WorkoutPlan {
  id: string;
  generatedPlan: string;
  createdAt: string;
}

export interface MealPlan {
  id: string;
  generatedPlan: string;
  createdAt: string;
}

export interface ProgressLog {
  id: string;
  workoutPlanId: string;
  date: string;
  notes?: string;
}
