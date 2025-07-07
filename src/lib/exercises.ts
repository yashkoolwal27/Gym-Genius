
export const exerciseData = {
  "Chest": ["Bench Press", "Incline Dumbbell Press", "Push-ups", "Cable Flys", "Dumbbell Pullover"],
  "Cardio": ["Running (Treadmill)", "Cycling (Stationary Bike)", "Jumping Jacks", "Burpees", "Rowing Machine"],
  "Arms": ["Bicep Curls", "Tricep Dips", "Hammer Curls", "Tricep Pushdowns", "Preacher Curls"],
  "Legs": ["Squats", "Lunges", "Leg Press", "Calf Raises", "Deadlifts"],
  "Core": ["Plank", "Crunches", "Leg Raises", "Russian Twists", "Ab Roller"],
  "Shoulders": ["Overhead Press", "Lateral Raises", "Front Raises", "Shrugs", "Arnold Press"],
  "Back": ["Pull-ups", "Bent-over Rows", "Lat Pulldowns", "Deadlifts", "T-Bar Rows"],
} as const;

export type ExerciseCategory = keyof typeof exerciseData;
