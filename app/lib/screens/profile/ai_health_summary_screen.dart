import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

class AIHealthSummaryScreen extends StatelessWidget {
  final UserProfile profile;

  const AIHealthSummaryScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    // Dynamically retrieve completion and details
    final name = profile.name.isNotEmpty ? profile.name.split(' ').first : 'Champ';
    final completion = profile.getCompletionPercentage();

    // Derived health score logic: basic starts at 70, increases with profile completion
    final double healthScore = (70.0 + (completion * 0.3)).clamp(0.0, 100.0);
    const double nutritionScore = 92.0;
    const double workoutConsistency = 85.0;
    const double recoveryScore = 76.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Health Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Score Card & Welcome message
            AppCard(
              child: Row(
                children: [
                  // Circular Health Score
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: healthScore / 100.0,
                          strokeWidth: 8,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${healthScore.round()}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                          ),
                          const Text(
                            '/100',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Greeting & Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Great Job, $name! 💪',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You are consistent with your workouts and nutrition. Keep pushing forward!',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Health Scores Overview'),
            const SizedBox(height: 10),

            // Scores Progress meters
            AppCard(
              child: Column(
                children: [
                  _buildScoreRow('Health Score', healthScore, AppColors.primary),
                  const SizedBox(height: 16),
                  _buildScoreRow('Nutrition Score', nutritionScore, AppColors.primaryBright),
                  const SizedBox(height: 16),
                  _buildScoreRow('Workout Consistency', workoutConsistency, AppColors.accent),
                  const SizedBox(height: 16),
                  _buildScoreRow('Recovery Score', recoveryScore, AppColors.accentPurple),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Coach Insight card
            const SectionHeader(title: 'AI Coach Insights'),
            const SizedBox(height: 10),

            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cute robot avatar
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  // Insights text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gemini AI Coach Feedback',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDynamicCoachingMessage(completion, healthScore),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
            Text('${score.round()}/100', style: TextStyle(fontWeight: FontWeight.bold, color: barColor, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100.0,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  String _getDynamicCoachingMessage(int completion, double healthScore) {
    if (completion < 50) {
      return "Hi there! I see your profile is still developing. Unlocking the 'Advanced Analytics' and completing metrics like Body Fat % or Sleep Duration will help me formulate more precise targets for you. Let's get those filled out!";
    } else if (healthScore < 85) {
      return "Awesome start! Your physical statistics are well set. I recommend focusing on logging recovery metrics like sleep quality and resting heart rate to boost your overall health index score to 90+.";
    } else {
      return "Phenomenal metrics! You are in the top tier of consistency. Your calorie levels and water target balance look perfectly in sync. Keep maintaining this streak and complete any remaining progress photos for monthly comparisons!";
    }
  }
}
