import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/nutrition_engine.dart';
import '../../widgets/shared_widgets.dart';

import 'food_search_screen.dart';
import 'todays_log_screen.dart';
import 'recipes_list_screen.dart';
import 'meal_insights_screen.dart';
import 'nutrition_summary_screen.dart';
import 'food_details_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final _firestoreService = FirestoreService();
  
  UserProfile? _profile;
  int _streakCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prof = await _firestoreService.getUserProfile().timeout(const Duration(seconds: 3));
      final streakData = await _firestoreService.updateAndGetStreak().timeout(const Duration(seconds: 3));
      setState(() {
        _profile = prof;
        _streakCount = streakData['streak'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Firestore failed to initialize user profile: $e');
      setState(() {
        _profile = UserProfile(uid: 'guest_user', basicProfile: {'name': 'Guest User'}, email: '');
        _streakCount = 0;
        _isLoading = false;
      });
    }
  }

  void _addWater(int amountMl) async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _firestoreService.logWater(todayStr, amountMl);
  }

  void _logFavoriteQuick(FoodItem food) async {
    final now = DateTime.now();
    final entry = MealEntry(
      id: const Uuid().v4(),
      userId: '',
      foodId: food.id,
      foodName: food.name,
      mealType: 'Breakfast', // default to breakfast for quick add
      quantity: 1.0,
      servingUnit: food.servingSize,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      fiber: food.fiber,
      sugar: food.sugar,
      sodium: food.sodium,
      imageUrl: food.imageUrl,
      timestamp: now.toIso8601String(),
    );

    await _firestoreService.addMealEntry(entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged 1 serving of ${food.name}! 🚀'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final profile = _profile ?? UserProfile(uid: 'guest', basicProfile: {'name': 'User'}, email: '');
    final goals = NutritionEngine.calculateTargets(profile);

    return StreamBuilder<List<MealEntry>>(
      stream: _firestoreService.getMealEntriesStream(todayStr),
      builder: (context, entriesSnapshot) {
        final entries = entriesSnapshot.data ?? [];
        
        // Sum macros
        double caloriesLogged = entries.fold(0.0, (sum, e) => sum + e.calories);
        double proteinLogged = entries.fold(0.0, (sum, e) => sum + e.protein);
        double carbsLogged = entries.fold(0.0, (sum, e) => sum + e.carbs);
        double fatLogged = entries.fold(0.0, (sum, e) => sum + e.fat);
        double fiberLogged = entries.fold(0.0, (sum, e) => sum + e.fiber);

        return StreamBuilder<int>(
          stream: _firestoreService.getWaterLogStream(todayStr),
          builder: (context, waterSnapshot) {
            final waterLoggedMl = waterSnapshot.data ?? 0;
            final waterLoggedL = waterLoggedMl / 1000.0;

            // Calculate local Nutrition Score
            final score = NutritionEngine.calculateNutritionScore(
              goalCalories: goals['calories']!,
              loggedCalories: caloriesLogged,
              goalProtein: goals['protein']!,
              loggedProtein: proteinLogged,
              goalWaterL: goals['water']!,
              loggedWaterL: waterLoggedL,
              goalFiber: goals['fiber']!,
              loggedFiber: fiberLogged,
            );

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text('Meal Planner'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined, color: AppColors.primary),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionSummaryScreen())),
                  ),
                  IconButton(
                    icon: const Icon(Icons.psychology, color: AppColors.primaryBright),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealInsightsScreen())),
                  ),
                  IconButton(
                    icon: const Icon(Icons.receipt_long, color: AppColors.accent),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TodaysLogScreen())),
                  ),
                  IconButton(
                    icon: const Icon(Icons.restaurant_menu, color: AppColors.accentOrange),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipesListScreen())),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Streak & Score Banner
                  _buildStreakScoreCard(score),
                  const SizedBox(height: 16),

                  // Daily Overview Circular Indicators
                  _buildDailyOverviewCard(goals, caloriesLogged, proteinLogged, carbsLogged, fatLogged, fiberLogged),
                  const SizedBox(height: 16),

                  // Interactive Water Tracker
                  _buildWaterTrackerCard(goals['water']!, waterLoggedMl),
                  const SizedBox(height: 20),

                  // Favorites Section
                  const SectionHeader(title: '⭐ Favorite Foods'),
                  const SizedBox(height: 10),
                  _buildFavoritesGrid(),
                  const SizedBox(height: 20),

                  // Meal Categories
                  const SectionHeader(title: 'Meal Categories'),
                  const SizedBox(height: 10),
                  _buildMealCategoryCard('Breakfast', entries.where((e) => e.mealType == 'Breakfast').toList()),
                  const SizedBox(height: 10),
                  _buildMealCategoryCard('Lunch', entries.where((e) => e.mealType == 'Lunch').toList()),
                  const SizedBox(height: 10),
                  _buildMealCategoryCard('Dinner', entries.where((e) => e.mealType == 'Dinner').toList()),
                  const SizedBox(height: 10),
                  _buildMealCategoryCard('Snacks', entries.where((e) => e.mealType == 'Snacks').toList()),
                  const SizedBox(height: 50),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                child: const Icon(Icons.search),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoodSearchScreen(initialMealType: 'Breakfast')),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStreakScoreCard(int score) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: AppColors.accentOrange, size: 24),
              const SizedBox(width: 8),
              Text(
                '🔥 $_streakCount Day Streak',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Nutrition Score: $score/100',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyOverviewCard(
    Map<String, double> goals,
    double calLogged,
    double protLogged,
    double carbsLogged,
    double fatLogged,
    double fibLogged,
  ) {
    double calGoal = goals['calories']!;
    double calPct = (calLogged / calGoal).clamp(0.0, 1.0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today Overview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              // Large circular calories progress ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: calPct,
                      strokeWidth: 8,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${calLogged.round()}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        '/ ${calGoal.round()} kcal',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Linear progress indicators for other macros
              Expanded(
                child: Column(
                  children: [
                    _MacroProgressLine(label: 'Protein', logged: protLogged, goal: goals['protein']!, color: AppColors.primaryBright, unit: 'g'),
                    const SizedBox(height: 10),
                    _MacroProgressLine(label: 'Carbs', logged: carbsLogged, goal: goals['carbs']!, color: AppColors.accent, unit: 'g'),
                    const SizedBox(height: 10),
                    _MacroProgressLine(label: 'Fat', logged: fatLogged, goal: goals['fat']!, color: AppColors.accentOrange, unit: 'g'),
                    const SizedBox(height: 10),
                    _MacroProgressLine(label: 'Fiber', logged: fibLogged, goal: goals['fiber']!, color: Colors.purpleAccent, unit: 'g'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTrackerCard(double goalL, int loggedMl) {
    double loggedL = loggedMl / 1000.0;
    double pct = (loggedL / goalL).clamp(0.0, 1.0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Water", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: pct,
                          strokeWidth: 4,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                      const Icon(Icons.local_drink, color: AppColors.accent, size: 20),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${loggedL.toStringAsFixed(1)} L / ${goalL.toStringAsFixed(0)} L', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                      const Text('Hydration target progress', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(65, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _addWater(250),
                    child: const Text('+250ml', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(65, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _addWater(500),
                    child: const Text('+500ml', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return StreamBuilder<List<FoodItem>>(
      stream: _firestoreService.getFavoriteFoodsStream(),
      builder: (context, snapshot) {
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Text(
            'Star favorite items on the Details screen for one-tap logging.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          );
        }
        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            itemBuilder: (context, index) {
              final food = list[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  onTap: () => _logFavoriteQuick(food),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 16),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
                          Text('${food.calories.round()} kcal', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMealCategoryCard(String mealType, List<MealEntry> list) {
    double totalCalories = list.fold(0.0, (sum, e) => sum + e.calories);
    double totalProtein = list.fold(0.0, (sum, e) => sum + e.protein);

    return AppCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodSearchScreen(initialMealType: mealType),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant, color: AppColors.accentPurple, size: 18),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mealType, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  Text('${list.length} item${list.length == 1 ? "" : "s"} logged', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${totalCalories.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('${totalProtein.toStringAsFixed(0)}g Protein', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroProgressLine extends StatelessWidget {
  final String label;
  final double logged;
  final double goal;
  final Color color;
  final String unit;
  const _MacroProgressLine({required this.label, required this.logged, required this.goal, required this.color, required this.unit});

  @override
  Widget build(BuildContext context) {
    double pct = (logged / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            Text('${logged.round()} / ${goal.round()} $unit', style: const TextStyle(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}
