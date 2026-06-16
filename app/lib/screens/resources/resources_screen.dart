import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/shared_widgets.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = [
      {
        'title': 'Mastering the Deadlift',
        'category': 'Technique',
        'readTime': '5 min',
        'color': AppColors.primary,
        'icon': Icons.fitness_center,
      },
      {
        'title': 'High Protein Meal Prep',
        'category': 'Nutrition',
        'readTime': '8 min',
        'color': AppColors.accentOrange,
        'icon': Icons.restaurant,
      },
      {
        'title': 'Recovery & Sleep Strategy',
        'category': 'Recovery',
        'readTime': '4 min',
        'color': AppColors.accent,
        'icon': Icons.bedtime,
      },
      {
        'title': 'Effective Cardio for Fat Loss',
        'category': 'Training',
        'readTime': '6 min',
        'color': AppColors.accentPurple,
        'icon': Icons.directions_run,
      },
      {
        'title': 'Supplements: Fact vs Fiction',
        'category': 'Nutrition',
        'readTime': '10 min',
        'color': AppColors.accentOrange,
        'icon': Icons.medication,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Educational Resources'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final res = resources[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (res['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(res['icon'] as IconData, color: res['color'] as Color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res['category'] as String,
                          style: TextStyle(color: res['color'] as Color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          res['title'] as String,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 12),
                            const SizedBox(width: 4),
                            Text(res['readTime'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
