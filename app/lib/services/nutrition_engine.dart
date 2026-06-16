import '../models/models.dart';

class NutritionEngine {
  // Calculates dynamic nutrition targets based on user profile
  static Map<String, double> calculateTargets(UserProfile profile) {
    // Mifflin-St Jeor BMR calculation
    double bmr = 10 * profile.weight + 6.25 * profile.height - 5 * profile.age + 5;

    // Activity level multiplier
    double multiplier = 1.2; // default sedentary
    final activity = profile.activityLevel.toLowerCase();
    if (activity.contains('light')) {
      multiplier = 1.375;
    } else if (activity.contains('mod')) {
      multiplier = 1.55;
    } else if (activity.contains('very') || activity.contains('active')) {
      multiplier = 1.725;
    } else if (activity.contains('extra')) {
      multiplier = 1.9;
    }

    double tdee = bmr * multiplier;

    // Adjust for fitness goals
    double dailyCalories = tdee;
    final goal = profile.fitnessGoal.toLowerCase();
    if (goal.contains('loss') || goal.contains('cut')) {
      dailyCalories -= 500;
    } else if (goal.contains('gain') || goal.contains('bulk')) {
      dailyCalories += 500;
    }

    // Guard minimum safe calories
    if (dailyCalories < 1200) dailyCalories = 1200;

    // Macronutrient splits: 30% Protein, 45% Carbs, 25% Fat
    double protein = (dailyCalories * 0.30) / 4;
    double carbs = (dailyCalories * 0.45) / 4;
    double fat = (dailyCalories * 0.25) / 9;
    double fiber = 30.0; // standard healthy target
    double water = 3.0;  // 3 liters

    return {
      'calories': double.parse(dailyCalories.toStringAsFixed(0)),
      'protein': double.parse(protein.toStringAsFixed(0)),
      'carbs': double.parse(carbs.toStringAsFixed(0)),
      'fat': double.parse(fat.toStringAsFixed(0)),
      'fiber': fiber,
      'water': water,
    };
  }

  // Local rule engine to calculate 0-100 Nutrition Score
  static int calculateNutritionScore({
    required double goalCalories,
    required double loggedCalories,
    required double goalProtein,
    required double loggedProtein,
    required double goalWaterL,
    required double loggedWaterL,
    required double goalFiber,
    required double loggedFiber,
  }) {
    if (loggedCalories == 0 && loggedProtein == 0 && loggedWaterL == 0) {
      return 0;
    }

    // 1. Calories Score (30 points) - penalize over/under budget
    double calDiff = (loggedCalories - goalCalories).abs();
    double calPct = (calDiff / goalCalories).clamp(0.0, 1.0);
    double calScore = 30 * (1.0 - calPct);

    // 2. Protein Score (30 points) - reward meeting protein goal
    double protPct = (loggedProtein / goalProtein).clamp(0.0, 1.5);
    double protScore = protPct >= 1.0 ? 30.0 : protPct * 30;

    // 3. Hydration Score (20 points)
    double waterPct = (loggedWaterL / goalWaterL).clamp(0.0, 1.5);
    double waterScore = waterPct >= 1.0 ? 20.0 : waterPct * 20;

    // 4. Fiber Score (20 points)
    double fiberPct = (loggedFiber / goalFiber).clamp(0.0, 1.5);
    double fiberScore = fiberPct >= 1.0 ? 20.0 : fiberPct * 20;

    double finalScore = calScore + protScore + waterScore + fiberScore;
    return finalScore.round().clamp(0, 100);
  }
}
