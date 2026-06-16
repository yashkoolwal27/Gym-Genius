import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/shared_widgets.dart';

class AchievementItem {
  final String title;
  final String status;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final double progress; // 0.0 to 1.0, or -1.0 if not applicable
  final String progressText;

  const AchievementItem({
    required this.title,
    required this.status,
    required this.icon,
    required this.color,
    this.isCompleted = false,
    this.progress = -1.0,
    this.progressText = '',
  });
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      const AchievementItem(
        title: 'First Workout',
        status: 'Completed',
        icon: Icons.fitness_center_rounded,
        color: AppColors.primary,
        isCompleted: true,
      ),
      const AchievementItem(
        title: '7 Day Streak',
        status: 'Completed',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.accentOrange,
        isCompleted: true,
      ),
      const AchievementItem(
        title: '30 Day Streak',
        status: 'Completed',
        icon: Icons.stars_rounded,
        color: AppColors.accentPurple,
        isCompleted: true,
      ),
      const AchievementItem(
        title: '100 Workouts',
        status: 'In Progress',
        icon: Icons.track_changes_rounded,
        color: Colors.blueAccent,
        progress: 0.45,
        progressText: '45/100',
      ),
      const AchievementItem(
        title: '10K Calories',
        status: 'In Progress',
        icon: Icons.local_fire_department_outlined,
        color: AppColors.warning,
        progress: 0.745,
        progressText: '7,450/10,000',
      ),
      const AchievementItem(
        title: 'Protein Master',
        status: 'Level 3',
        icon: Icons.restaurant_menu_rounded,
        color: AppColors.primaryBright,
        isCompleted: true,
      ),
      const AchievementItem(
        title: 'Weight Goal',
        status: 'In Progress',
        icon: Icons.monitor_weight_outlined,
        color: Colors.tealAccent,
        progress: 0.6,
        progressText: '60% Target',
      ),
      const AchievementItem(
        title: 'Early Bird',
        status: 'Locked',
        icon: Icons.wb_sunny_outlined,
        color: AppColors.textMuted,
      ),
      const AchievementItem(
        title: 'Consistency Pro',
        status: 'Locked',
        icon: Icons.verified_user_outlined,
        color: AppColors.textMuted,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final item = achievements[index];
          final isLocked = item.status == 'Locked';
          final iconBgColor = isLocked
              ? AppColors.cardBg2
              : item.color.withValues(alpha: 0.12);

          return AppCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLocked
                          ? AppColors.border
                          : item.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_outline_rounded : item.icon,
                    color: isLocked ? AppColors.textMuted : item.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Status Description
                Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isLocked
                        ? AppColors.textMuted
                        : item.isCompleted
                            ? AppColors.primary
                            : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),

                // Progress Indicator if applicable
                if (item.progress >= 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(item.color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.progressText,
                    style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
