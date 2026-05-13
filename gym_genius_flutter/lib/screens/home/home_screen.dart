import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  List<WorkoutLog> _recentWorkouts = [];
  List<MealLog> _recentMeals = [];
  List<WeightLog> _weightLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final workouts = await _firestoreService.getWorkoutLogs();
      final meals = await _firestoreService.getMealLogs();
      final weights = await _firestoreService.getWeightLogs();
      if (mounted) {
        setState(() {
          _recentWorkouts = workouts.take(3).toList();
          _recentMeals = meals.take(3).toList();
          _weightLogs = weights;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _latestWeight =>
      _weightLogs.isNotEmpty ? _weightLogs.last.weight : 82.0;

  String get _weightChangeText {
    if (_weightLogs.length < 2) return '-0.5 kg this week';
    final diff = _weightLogs.last.weight - _weightLogs[_weightLogs.length - 2].weight;
    return '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg from last entry';
  }

  int get _workoutsThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _recentWorkouts.where((w) {
      try {
        final date = DateTime.parse(w.date);
        return date.isAfter(weekStart.subtract(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }).length;
  }

  void _showWeightLogDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Weight', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current: ${_latestWeight.toStringAsFixed(1)} kg',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'New Weight (kg)',
                suffixText: 'kg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val != null) {
                final log = WeightLog(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  weight: val,
                );
                await _firestoreService.addWeightLog(log);
                if (mounted) {
                  Navigator.pop(ctx);
                  _loadData();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.cardBg,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.background,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.black, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Gym Genius',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverToBoxAdapter(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting
                          const Text(
                            'Your Dashboard 💪',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'An overview of your fitness journey.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),

                          // Stat Cards Grid
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.0,
                            children: [
                              GradientStatCard(
                                title: 'Workouts This Week',
                                value: '$_workoutsThisWeek',
                                change: '+1 from last week',
                                icon: Icons.bolt_rounded,
                                accentColor: AppColors.primary,
                              ),
                              GradientStatCard(
                                title: 'Active Calories',
                                value: '1,850',
                                change: '-150 from yesterday',
                                icon: Icons.local_fire_department_rounded,
                                accentColor: AppColors.accentOrange,
                              ),
                              GradientStatCard(
                                title: 'Current Weight',
                                value: '${_latestWeight.toStringAsFixed(1)} kg',
                                change: _weightChangeText,
                                icon: Icons.monitor_weight_outlined,
                                accentColor: AppColors.accent,
                                onTap: _showWeightLogDialog,
                              ),
                              GradientStatCard(
                                title: 'Workout Streak',
                                value: '5 days 🔥',
                                change: 'Keep it up!',
                                icon: Icons.calendar_today_rounded,
                                accentColor: AppColors.accentPurple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions
                          const SectionHeader(title: 'Quick Actions'),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 0.85,
                            children: [
                              QuickActionButton(
                                label: 'AI Workout',
                                icon: Icons.fitness_center,
                                color: AppColors.primary,
                                onTap: () => _navigateTo(context, 1),
                              ),
                              QuickActionButton(
                                label: 'Meal Plan',
                                icon: Icons.restaurant_menu,
                                color: AppColors.accentOrange,
                                onTap: () => _navigateTo(context, 3),
                              ),
                              QuickActionButton(
                                label: 'Progress',
                                icon: Icons.show_chart,
                                color: AppColors.accent,
                                onTap: () => _navigateTo(context, 2),
                              ),
                              QuickActionButton(
                                label: 'Articles',
                                icon: Icons.menu_book_rounded,
                                color: AppColors.accentPurple,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Recent Workouts
                          SectionHeader(
                            title: 'Recent Workouts',
                            actionLabel: 'See All',
                            onAction: () => _navigateTo(context, 1),
                          ),
                          const SizedBox(height: 12),
                          if (_recentWorkouts.isEmpty)
                            AppCard(
                              child: const EmptyState(
                                icon: Icons.fitness_center,
                                title: 'No workouts yet',
                                subtitle: 'Start logging your workouts!',
                              ),
                            )
                          else
                            ...(_recentWorkouts.map((w) => _WorkoutLogTile(workout: w))),
                          const SizedBox(height: 24),

                          // Recent Meals
                          SectionHeader(
                            title: 'Recent Meals',
                            actionLabel: 'See All',
                            onAction: () => _navigateTo(context, 3),
                          ),
                          const SizedBox(height: 12),
                          if (_recentMeals.isEmpty)
                            AppCard(
                              child: const EmptyState(
                                icon: Icons.restaurant,
                                title: 'No meals logged',
                                subtitle: 'Track your nutrition!',
                              ),
                            )
                          else
                            ...(_recentMeals.map((m) => _MealLogTile(meal: m))),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    // Navigate via bottom nav - will be handled by main shell
    final scaffold = context.findAncestorStateOfType<State>();
    // Fallback: just show snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Use bottom navigation'),
        backgroundColor: AppColors.cardBg,
      ),
    );
  }
}

class _WorkoutLogTile extends StatelessWidget {
  final WorkoutLog workout;
  const _WorkoutLogTile({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.exerciseTypes.join(', '),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${workout.exercises.length} exercises • ${workout.date}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _MealLogTile extends StatelessWidget {
  final MealLog meal;
  const _MealLogTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: AppColors.accentOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.mealType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${meal.foodCategory} • ${meal.macronutrients}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
