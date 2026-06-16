import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../services/ai_service.dart';
import '../../widgets/shared_widgets.dart';

class AITrainerScreen extends StatefulWidget {
  const AITrainerScreen({super.key});

  @override
  State<AITrainerScreen> createState() => _AITrainerScreenState();
}

class _AITrainerScreenState extends State<AITrainerScreen> {
  final _aiService = AIService();
  final _firestoreService = FirestoreService();
  bool _isAnalyzing = false;
  String? _feedback;

  Future<void> _getFeedback() async {
    setState(() {
      _isAnalyzing = true;
      _feedback = null;
    });
    try {
      final workouts = await _firestoreService.getWorkoutLogs();
      final meals = await _firestoreService.getMealLogs();
      final weights = await _firestoreService.getWeightLogs();

      if (workouts.isEmpty && meals.isEmpty && weights.isEmpty) {
        throw 'Not enough data to analyze. Please log some workouts, meals, or weight first.';
      }

      final response = await _aiService.getAITrainerFeedback(
        workoutLogs: workouts,
        mealLogs: meals,
        weightLogs: weights,
      );
      setState(() => _feedback = response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Personal Trainer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  const Icon(Icons.psychology_outlined, color: AppColors.primary, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Get Expert Analysis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'I will analyze your recent logs to provide personalized feedback on your progress, nutrition, and training.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: _isAnalyzing ? 'Analyzing Data...' : 'Generate Analysis',
                    onPressed: _isAnalyzing ? null : _getFeedback,
                    isLoading: _isAnalyzing,
                    icon: Icons.auto_awesome,
                  ),
                ],
              ),
            ),
            if (_feedback != null) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Trainer Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    Text(
                      _feedback!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
