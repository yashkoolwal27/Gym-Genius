import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants.dart';
import '../models/models.dart';

class AIService {
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
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

Please provide a structured workout plan with:
1. Warm-up routine (5 minutes)
2. Main workout with exercises, sets, reps, and rest periods
3. Cool-down routine (5 minutes)
4. Key tips and safety notes

Format each exercise clearly with: Exercise name, Sets x Reps, Rest period, and brief instructions.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate workout plan. Please try again.';
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
}
