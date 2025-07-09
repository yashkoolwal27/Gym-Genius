
export interface Exercise {
  name: string;
  image: string;
  hint: string;
}

export interface SubCategory {
  name: string;
  exercises: readonly Exercise[];
}

export interface SubCategoryData {
    subCategories: readonly SubCategory[];
}

export type CategoryData = readonly Exercise[] | SubCategoryData;

export const exerciseData: Record<string, CategoryData> = {
  "Chest": {
    subCategories: [
      {
        name: "Upper Chest",
        exercises: [
          { name: "Incline Dumbbell Press", image: "https://placehold.co/100x100.png", hint: "incline press" },
          { name: "Incline Bench Press", image: "https://placehold.co/100x100.png", hint: "incline bench press" },
          { name: "Low-to-High Cable Fly", image: "https://placehold.co/100x100.png", hint: "cable fly" },
        ]
      },
      {
        name: "Middle Chest",
        exercises: [
          { name: "Bench Press", image: "https://placehold.co/100x100.png", hint: "bench press" },
          { name: "Dumbbell Press", image: "https://placehold.co/100x100.png", hint: "dumbbell press" },
          { name: "Push-ups", image: "https://placehold.co/100x100.png", hint: "push up" },
          { name: "Cable Flys", image: "https://placehold.co/100x100.png", hint: "cable fly" },
        ]
      },
      {
        name: "Lower Chest",
        exercises: [
          { name: "Decline Bench Press", image: "https://placehold.co/100x100.png", hint: "decline bench press" },
          { name: "Decline Dumbbell Press", image: "https://placehold.co/100x100.png", hint: "decline dumbbell press" },
          { name: "High-to-Low Cable Fly", image: "https://placehold.co/100x100.png", hint: "high low cable fly" },
          { name: "Dips (Chest)", image: "https://placehold.co/100x100.png", hint: "chest dip" },
        ]
      }
    ]
  },
  "Cardio": [
    { name: "Running (Treadmill)", image: "https://placehold.co/100x100.png", hint: "treadmill run" },
    { name: "Cycling (Stationary Bike)", image: "https://placehold.co/100x100.png", hint: "stationary bike" },
    { name: "Jumping Jacks", image: "https://placehold.co/100x100.png", hint: "jumping jack" },
    { name: "Burpees", image: "https://placehold.co/100x100.png", hint: "burpee exercise" },
    { name: "Rowing Machine", image: "https://placehold.co/100x100.png", hint: "rowing machine" }
  ],
  "Biceps": {
    subCategories: [
      {
        name: "Biceps Brachii",
        exercises: [
          { name: "Bicep Curls", image: "https://placehold.co/100x100.png", hint: "bicep curl" },
          { name: "Preacher Curls", image: "https://placehold.co/100x100.png", hint: "preacher curl" },
          { name: "Concentration Curls", image: "https://placehold.co/100x100.png", hint: "concentration curl" },
          { name: "Incline Dumbbell Curls", image: "https://placehold.co/100x100.png", hint: "incline dumbbell curl" }
        ]
      },
      {
        name: "Brachialis",
        exercises: [
          { name: "Hammer Curls", image: "https://placehold.co/100x100.png", hint: "hammer curl" },
        ]
      },
      {
        name: "Brachioradialis",
        exercises: [
          { name: "Reverse Barbell Curl", image: "https://placehold.co/100x100.png", hint: "reverse barbell curl" }
        ]
      }
    ]
  },
  "Triceps": {
    subCategories: [
      {
        name: "Long Head",
        exercises: [
          { name: "Skull Crushers", image: "https://placehold.co/100x100.png", hint: "skull crusher" },
          { name: "Overhead Dumbbell Extension", image: "https://placehold.co/100x100.png", hint: "overhead extension" }
        ]
      },
      {
        name: "Lateral Head",
        exercises: [
          { name: "Tricep Dips", image: "https://placehold.co/100x100.png", hint: "tricep dip" },
          { name: "Tricep Pushdowns", image: "https://placehold.co/100x100.png", hint: "tricep pushdown" }
        ]
      },
      {
        name: "Medial Head",
        exercises: [
          { name: "Reverse Grip Tricep Pushdown", image: "https://placehold.co/100x100.png", hint: "reverse grip pushdown" },
          { name: "Close-Grip Bench Press", image: "https://placehold.co/100x100.png", hint: "close grip bench press" }
        ]
      }
    ]
  },
  "Forearms": {
    subCategories: [
        {
            name: "Extensor Digitorum",
            exercises: [
                { name: "Reverse Wrist Curls", image: "https://placehold.co/100x100.png", hint: "reverse wrist curl" }
            ]
        },
        {
            name: "Extensor Carpi Ulnaris",
            exercises: [
                { name: "Ulnar Deviation", image: "https://placehold.co/100x100.png", hint: "ulnar deviation" }
            ]
        }
    ]
  },
  "Legs": {
    subCategories: [
      {
        name: "Quads",
        exercises: [
          { name: "Squats", image: "https://placehold.co/100x100.png", hint: "barbell squat" },
          { name: "Leg Press", image: "https://placehold.co/100x100.png", hint: "leg press machine" },
          { name: "Lunges", image: "https://placehold.co/100x100.png", hint: "dumbbell lunge" },
          { name: "Leg Extensions", image: "https://placehold.co/100x100.png", hint: "leg extension machine" },
        ]
      },
      {
        name: "Hamstrings",
        exercises: [
          { name: "Romanian Deadlifts", image: "https://placehold.co/100x100.png", hint: "romanian deadlift" },
          { name: "Lying Leg Curls", image: "https://placehold.co/100x100.png", hint: "leg curl machine" },
        ]
      },
      {
        name: "Glutes",
        exercises: [
          { name: "Hip Thrusts", image: "https://placehold.co/100x100.png", hint: "barbell hip thrust" },
          { name: "Deadlifts", image: "https://placehold.co/100x100.png", hint: "barbell deadlift" },
        ]
      },
      {
        name: "Calves",
        exercises: [
          { name: "Standing Calf Raises", image: "https://placehold.co/100x100.png", hint: "standing calf raise" },
          { name: "Seated Calf Raises", image: "https://placehold.co/100x100.png", hint: "seated calf raise" },
        ]
      }
    ]
  },
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

export type ExerciseCategory = keyof typeof exerciseData;
