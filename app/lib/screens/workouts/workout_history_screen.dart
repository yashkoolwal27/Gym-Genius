import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';
import 'workouts_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final _firestoreService = FirestoreService();
  String _selectedMuscleFilter = 'All';

  void _showLogWorkoutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const LogWorkoutStepper(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> muscleFilters = ['All', 'Chest', 'Back', 'Legs', 'Arms'];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogWorkoutDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Plan Workout', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: muscleFilters.map((filter) {
                final isSelected = _selectedMuscleFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.cardBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedMuscleFilter = filter);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<WorkoutLog>>(
              stream: _firestoreService.getWorkoutLogsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final allLogs = snapshot.data ?? [];
                final logs = allLogs.where((log) {
                  if (_selectedMuscleFilter == 'All') return true;
                  return log.exerciseTypes.any((t) => t.toLowerCase() == _selectedMuscleFilter.toLowerCase());
                }).toList();

                if (logs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.fitness_center,
                    title: 'No workouts logged',
                    subtitle: 'Tap the button below to log your first workout!',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: logs.length,
                  itemBuilder: (_, i) => _WorkoutHistoryCard(
                    log: logs[i],
                    onDelete: () {
                      _firestoreService.deleteWorkoutLog(logs[i].id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutLog log;
  final VoidCallback onDelete;
  const _WorkoutHistoryCard({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.exerciseTypes.join(', '),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${log.date} • ${log.time}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 18),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (log.exercises.isNotEmpty) ...[
              const Divider(color: AppColors.border),
              ...log.exercises.take(3).map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 5, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(e.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const Spacer(),
                    Text('${e.sets.length} sets', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              )),
              if (log.exercises.length > 3)
                Text('+${log.exercises.length - 3} more', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}
