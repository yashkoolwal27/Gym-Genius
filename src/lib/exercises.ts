
export interface Exercise {
  name: string;
  image: string;
  hint: string;
}

export type ExerciseCategory = keyof typeof exerciseData;

export const exerciseData: Record<ExerciseCategory, readonly Exercise[]> = {
  "Chest": [
    { name: "Bench Press", image: "https://placehold.co/100x100.png", hint: "bench press" },
    { name: "Incline Dumbbell Press", image: "https://placehold.co/100x100.png", hint: "incline press" },
    { name: "Push-ups", image: "https://placehold.co/100x100.png", hint: "push up" },
    { name: "Cable Flys", image: "https://placehold.co/100x100.png", hint: "cable fly" },
    { name: "Dumbbell Pullover", image: "https://placehold.co/100x100.png", hint: "dumbbell pullover" }
  ],
  "Cardio": [
    { name: "Running (Treadmill)", image: "https://placehold.co/100x100.png", hint: "treadmill run" },
    { name: "Cycling (Stationary Bike)", image: "https://placehold.co/100x100.png", hint: "stationary bike" },
    { name: "Jumping Jacks", image: "https://placehold.co/100x100.png", hint: "jumping jack" },
    { name: "Burpees", image: "https://placehold.co/100x100.png", hint: "burpee exercise" },
    { name: "Rowing Machine", image: "https://placehold.co/100x100.png", hint: "rowing machine" }
  ],
  "Arms": [
    { name: "Bicep Curls", image: "https://placehold.co/100x100.png", hint: "bicep curl" },
    { name: "Tricep Dips", image: "https://placehold.co/100x100.png", hint: "tricep dip" },
    { name: "Hammer Curls", image: "https://placehold.co/100x100.png", hint: "hammer curl" },
    { name: "Tricep Pushdowns", image: "https://placehold.co/100x100.png", hint: "tricep pushdown" },
    { name: "Preacher Curls", image: "https://placehold.co/100x100.png", hint: "preacher curl" }
  ],
  "Legs": [
    { name: "Squats", image: "https://placehold.co/100x100.png", hint: "barbell squat" },
    { name: "Lunges", image: "https://placehold.co/100x100.png", hint: "dumbbell lunge" },
    { name: "Leg Press", image: "https://placehold.co/100x100.png", hint: "leg press machine" },
    { name: "Calf Raises", image: "https://placehold.co/100x100.png", hint: "calf raise" },
    { name: "Deadlifts", image: "https://placehold.co/100x100.png", hint: "barbell deadlift" }
  ],
  "Core": [
    { name: "Plank", image: "https://placehold.co/100x100.png", hint: "plank exercise" },
    { name: "Crunches", image: "https://placehold.co/100x100.png", hint: "floor crunch" },
    { name: "Leg Raises", image: "https://placehold.co/100x100.png", hint: "leg raise" },
    { name: "Russian Twists", image: "https://placehold.co/100x100.png", hint: "russian twist" },
    { name: "Ab Roller", image: "https://placehold.co/100x100.png", hint: "ab roller" }
  ],
  "Shoulders": [
    { name: "Overhead Press", image: "https://placehold.co/100x100.png", hint: "overhead press" },
    { name: "Lateral Raises", image: "https://placehold.co/100x100.png", hint: "lateral raise" },
    { name: "Front Raises", image: "https://placehold.co/100x100.png", hint: "front raise" },
    { name: "Shrugs", image: "https://placehold.co/100x100.png", hint: "dumbbell shrug" },
    { name: "Arnold Press", image: "https://placehold.co/100x100.png", hint: "arnold press" }
  ],
  "Back": [
    { name: "Pull-ups", image: "https://placehold.co/100x100.png", hint: "pull up" },
    { name: "Bent-over Rows", image: "https://placehold.co/100x100.png", hint: "bent over row" },
    { name: "Lat Pulldowns", image: "https://placehold.co/100x100.png", hint: "lat pulldown" },
    { name: "Deadlifts", image: "https://placehold.co/100x100.png", hint: "barbell deadlift" },
    { name: "T-Bar Rows", image: "https://placehold.co/100x100.png", hint: "t-bar row" }
  ],
} as const;
