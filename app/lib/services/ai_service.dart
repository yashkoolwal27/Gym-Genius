import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants.dart';
import '../models/models.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  // ─── AI Workout Generator ───
  Future<String> generateWorkoutPlan({
    required String fitnessGoal,
    required String experienceLevel,
    required List<String> targetMuscles,
    required int durationMinutes,
    String? equipment,
  }) async {
    final prompt = '''
You are an expert fitness coach. Generate a detailed, personalized workout plan.

User Details:
- Fitness Goal: $fitnessGoal
- Experience Level: $experienceLevel
- Target Muscles: ${targetMuscles.join(', ')}
- Duration: $durationMinutes minutes
- Available Equipment: ${equipment ?? 'Standard gym equipment'}

Please provide a strictly formatted JSON response for the workout plan.
The JSON should have this structure:
{
  "title": "A descriptive title for the workout",
  "exercises": [
    {
      "category": "String (e.g., Chest, Back, Legs)",
      "exerciseName": "String",
      "sets": Integer,
      "reps": "String (e.g., 10-12)",
      "weightRecommendation": "String",
      "restBetweenSets": Integer (in seconds, e.g., 60),
      "restAfterExercise": Integer (in seconds, e.g., 120),
      "tipsOrGoal": "String"
    }
  ]
}

Ensure the output is pure JSON, without any markdown formatting like ```json.
''';

    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
      return response.text ?? '{}';
    } catch (e) {
      throw 'Failed to generate workout plan. Please check your connection.';
    }
  }

  Future<String> generateWorkoutPlanFromProfile({
    required UserProfile profile,
  }) async {
    final prompt = '''
You are an expert fitness coach. Generate a personalized workout plan based on the user's profile.

User Details:
- Name: ${profile.name}
- Age: ${profile.age}
- Height: ${profile.height} cm
- Weight: ${profile.weight} kg
- Fitness Goal: ${profile.fitnessGoal}
- Activity Level: ${profile.activityLevel}

Please provide a strictly formatted JSON response for a full-body workout plan tailored to their profile.
The JSON should have this structure:
{
  "title": "A descriptive title for the workout",
  "exercises": [
    {
      "category": "String (e.g., Chest, Back, Legs)",
      "exerciseName": "String",
      "sets": Integer,
      "reps": "String (e.g., 10-12)",
      "weightRecommendation": "String",
      "restBetweenSets": Integer (in seconds, e.g., 60),
      "restAfterExercise": Integer (in seconds, e.g., 120),
      "tipsOrGoal": "String"
    }
  ]
}

Ensure the output is pure JSON, without any markdown formatting like ```json.
''';

    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
      return response.text ?? '{}';
    } catch (e) {
      throw 'Failed to generate workout plan. Please check your connection.';
    }
  }

  // ─── AI Meal Planner ───
  Future<String> generateMealPlan({
    required String fitnessGoal,
    required String macroPreference,
    required String mealType,
    required String foodCategory,
    String? dietaryRestrictions,
  }) async {
    final prompt = '''
You are a certified nutritionist and meal planning expert. Create a detailed meal plan.

User Requirements:
- Fitness Goal: $fitnessGoal
- Macro Preference: $macroPreference
- Meal Type: $mealType
- Food Category: $foodCategory
- Dietary Restrictions: ${dietaryRestrictions ?? 'None'}

Please provide:
1. A complete meal plan for this meal type
2. Exact portions and serving sizes
3. Estimated calories, protein, carbs, and fats
4. Preparation instructions
5. Nutritional benefits and tips

Make the meal plan practical, delicious, and aligned with the fitness goal.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate meal plan. Please try again.';
    } catch (e) {
      throw 'Failed to generate meal plan. Please check your connection.';
    }
  }

  // ─── AI Trainer Feedback ───
  Future<String> getAITrainerFeedback({
    required List<WorkoutLog> workoutLogs,
    required List<MealLog> mealLogs,
    required List<WeightLog> weightLogs,
  }) async {
    final workoutSummary = workoutLogs.take(10).map((w) =>
        '${w.date}: ${w.exerciseTypes.join(', ')} (${w.exercises.length} exercises)').join('\n');

    final mealSummary = mealLogs.take(10).map((m) =>
        '${m.date} - ${m.mealType}: ${m.mealDetails} (${m.macronutrients})').join('\n');

    final weightSummary = weightLogs.take(10).map((w) =>
        '${w.date}: ${w.weight} kg').join('\n');

    final prompt = '''
You are an expert AI fitness trainer and nutritionist. Analyze the user's fitness data and provide comprehensive, personalized feedback and advice.

Recent Workout History:
$workoutSummary

Recent Meal History:
$mealSummary

Weight Progress:
$weightSummary

Please provide detailed feedback covering:
### Overall Assessment
Brief summary of their current fitness journey.

### Workout Analysis
Strengths, areas for improvement, and specific recommendations.

### Nutrition Analysis
Diet quality assessment and meal timing recommendations.

### Progress Evaluation
Weight trend analysis and goal alignment.

### Action Plan
3-5 specific, actionable steps for the next week.

### Motivational Note
An encouraging, personalized message to keep them going.

Be specific, data-driven, and encouraging. Use markdown formatting.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate feedback. Please try again.';
    } catch (e) {
      throw 'Failed to get AI feedback. Please check your connection.';
    }
  }

  // ─── Educational Content ───
  Future<String> getExerciseTips(String exerciseName) async {
    final prompt = '''
You are a certified personal trainer. Provide a comprehensive guide for the exercise: "$exerciseName"

Include:
1. **Proper Form**: Step-by-step instructions
2. **Common Mistakes**: What to avoid
3. **Muscles Worked**: Primary and secondary muscles
4. **Variations**: 2-3 variations for different levels
5. **Safety Tips**: Important precautions
6. **Pro Tips**: Advanced techniques for better results

Keep it practical and easy to understand.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to get exercise tips.';
    } catch (e) {
      throw 'Failed to get exercise tips.';
    }
  }

  // ─── AI Meal Insights ───
  Future<String> getAIMealInsights({
    required List<MealEntry> mealEntries,
    required Map<String, double> goals,
    required UserProfile profile,
    required double loggedCalories,
    required double loggedProtein,
    required double loggedCarbs,
    required double loggedFat,
    required double loggedFiber,
    required double loggedWater,
  }) async {
    final mealSummary = mealEntries.map((e) =>
        '- ${e.mealType}: ${e.foodName} (${e.quantity} x ${e.servingUnit}) -> ${e.calories} kcal, ${e.protein}g Protein, ${e.carbs}g Carbs, ${e.fat}g Fat').join('\n');

    final prompt = '''
You are an expert AI sports nutritionist. Analyze the user's food log for today and provide actionable feedback.

User Details:
- Name: ${profile.name}
- Fitness Goal: ${profile.fitnessGoal}
- Target: ${goals['calories']} kcal, ${goals['protein']}g Protein, ${goals['carbs']}g Carbs, ${goals['fat']}g Fat, ${goals['fiber']}g Fiber, ${goals['water']}L Water

Today's Consumption:
- Total Calories: ${loggedCalories} kcal
- Total Protein: ${loggedProtein}g
- Total Carbs: ${loggedCarbs}g
- Total Fat: ${loggedFat}g
- Total Fiber: ${loggedFiber}g
- Total Water Intake: ${loggedWater}L

Today's Food Log:
$mealSummary

Please provide:
1. **Critical Deficiencies / Feedback**: Highlight if they are too low or high on calories, protein, carbs, fat, fiber, or water compared to targets.
2. **AI Food Recommendations**: Suggest 3-4 specific foods (especially highlighting local Indian or clean gym foods like Paneer, Egg, Roti, Chana, Dal, Banana, Oats) they should add to meet their goals.
3. **Action Plan for Tomorrow**: 2-3 specific, easy actions for improved nutrition.

Keep the tone encouraging, casual, and friendly. Use clear markdown formatting.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate nutrition insights. Please try again.';
    } catch (e) {
      throw 'Failed to connect with AI Coach. Please check your internet.';
    }
  }

  // ─── AI Food Item Generator ───
  Future<FoodItem> generateFoodItemFromQuery(String query) async {
    final prompt = '''
You are an expert nutritionist. Based on the user's food request: "$query", generate the complete standard nutrition facts for this food item.
Your response MUST be a strictly formatted JSON object matching this structure:
{
  "name": "Clean capitalized food name (e.g. Oats, Maggi Noodles, Pepperoni Pizza)",
  "servingSize": "The base serving size label (e.g. 100g, 1 pack, 1 slice)",
  "calories": double (in kcal, e.g. 389.0),
  "protein": double (in grams),
  "carbs": double (in grams),
  "fat": double (in grams),
  "fiber": double (in grams),
  "sugar": double (in grams),
  "sodium": double (in mg),
  "imageUrl": "A valid public image URL of the food if available, otherwise leave empty",
  "micronutrients": {
    "Vitamin A": double (in % DV, e.g. 15.0),
    "Vitamin C": double (in % DV),
    "Vitamin D": double (in % DV),
    "Vitamin E": double (in % DV),
    "Calcium": double (in % DV),
    "Iron": double (in % DV),
    "Zinc": double (in % DV)
  },
  "servings": [
    {
      "name": "Standard serving name (e.g. 100g, 1 pack)",
      "grams": double (the equivalent weight in grams, e.g. 100.0 or 70.0),
      "multiplier": double (multiplier relative to base serving size, usually 1.0)
    }
  ]
}

Provide ONLY the raw JSON. Do not include markdown code block formatting (such as ```json).
If you cannot identify the food, estimate the closest common food item.
''';

    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
      final jsonText = response.text ?? '{}';
      final Map<String, dynamic> data = json.decode(jsonText);
      
      final foodId = 'gemini_${DateTime.now().millisecondsSinceEpoch}';
      data['id'] = foodId;
      data['lastUpdated'] = DateTime.now().toIso8601String();
      
      return FoodItem.fromMap(data);
    } catch (e) {
      throw 'Failed to parse food details from Gemini: $e';
    }
  }
}
