class AppConstants {
  // Firebase / Gemini
  static const String geminiApiKey = 'AIzaSyBLXmKtJB8ZhPBPkxX8YDFk1LsSp_OG13E';
  static const String firebaseProjectId = 'gym-genius-7v97e';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String workoutLogsCollection = 'workoutLogs';
  static const String mealLogsCollection = 'mealLogs';
  static const String weightLogsCollection = 'weightLogs';
  static const String workoutPlansCollection = 'workoutPlans';
  static const String mealPlansCollection = 'mealPlans';

  // SharedPreferences Keys
  static const String prefWeightLogs = 'weight-logs';
  static const String prefUserProfile = 'user-profile';

  // Exercise Categories
  static const List<String> exerciseTypes = [
    'Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Core', 'Cardio', 'Full Body'
  ];

  // Meal Types
  static const List<String> mealTypes = [
    'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-workout', 'Post-workout'
  ];

  // Fitness Goals
  static const List<String> fitnessGoals = [
    'Weight Loss', 'Muscle Gain', 'Maintenance', 'Endurance', 'Flexibility'
  ];

  // Food Categories
  static const List<String> foodCategories = [
    'Proteins', 'Carbohydrates', 'Fats', 'Vegetables', 'Fruits', 'Dairy', 'Beverages'
  ];

  // Macronutrient Options
  static const List<String> macroOptions = [
    'High Protein', 'Low Carb', 'Balanced', 'High Carb', 'Keto', 'Vegan'
  ];
}
