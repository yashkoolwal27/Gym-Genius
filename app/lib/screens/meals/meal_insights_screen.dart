import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/ai_service.dart';
import '../../services/nutrition_engine.dart';
import '../../widgets/shared_widgets.dart';

class MealInsightsScreen extends StatefulWidget {
  const MealInsightsScreen({super.key});

  @override
  State<MealInsightsScreen> createState() => _MealInsightsScreenState();
}

class _MealInsightsScreenState extends State<MealInsightsScreen> {
  final _firestoreService = FirestoreService();
  final _aiService = AIService();

  bool _isGeneratingReport = false;
  String? _aiReport;
  
  UserProfile? _profile;
  List<MealEntry> _todayEntries = [];
  int _waterMl = 0;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final prof = await _firestoreService.getUserProfile();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final entries = await _firestoreService.getMealEntriesForDate(todayStr);
      final water = await _firestoreService.getWaterLog(todayStr);

      setState(() {
        _profile = prof;
        _todayEntries = entries;
        _waterMl = water;
        _isLoadingData = false;
      });
    } catch (e) {
      debugPrint('Firestore failed to initialize user insights data: $e');
      setState(() {
        _profile = UserProfile(uid: 'guest_user', basicProfile: {'name': 'Guest User'}, email: '');
        _todayEntries = [];
        _waterMl = 0;
        _isLoadingData = false;
      });
    }
  }

  Future<void> _generateAIReport() async {
    if (_profile == null) return;
    setState(() {
      _isGeneratingReport = true;
      _aiReport = null;
    });

    final goals = NutritionEngine.calculateTargets(_profile!);
    double loggedCalories = _todayEntries.fold(0.0, (sum, item) => sum + item.calories);
    double loggedProtein = _todayEntries.fold(0.0, (sum, item) => sum + item.protein);
    double loggedCarbs = _todayEntries.fold(0.0, (sum, item) => sum + item.carbs);
    double loggedFat = _todayEntries.fold(0.0, (sum, item) => sum + item.fat);
    double loggedFiber = _todayEntries.fold(0.0, (sum, item) => sum + item.fiber);
    double loggedWater = _waterMl / 1000.0;

    try {
      final report = await _aiService.getAIMealInsights(
        mealEntries: _todayEntries,
        goals: goals,
        profile: _profile!,
        loggedCalories: loggedCalories,
        loggedProtein: loggedProtein,
        loggedCarbs: loggedCarbs,
        loggedFat: loggedFat,
        loggedFiber: loggedFiber,
        loggedWater: loggedWater,
      );
      setState(() => _aiReport = report);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isGeneratingReport = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Default calculations if profile is missing
    final profile = _profile ?? UserProfile(uid: 'guest', basicProfile: {'name': 'User'}, email: '');
    final goals = NutritionEngine.calculateTargets(profile);
    
    double loggedCalories = _todayEntries.fold(0.0, (sum, item) => sum + item.calories);
    double loggedProtein = _todayEntries.fold(0.0, (sum, item) => sum + item.protein);
    double loggedCarbs = _todayEntries.fold(0.0, (sum, item) => sum + item.carbs);
    double loggedFat = _todayEntries.fold(0.0, (sum, item) => sum + item.fat);
    double loggedFiber = _todayEntries.fold(0.0, (sum, item) => sum + item.fiber);
    double loggedWaterL = _waterMl / 1000.0;

    // Local rules
    final calDeficit = goals['calories']! - loggedCalories;
    final protDeficit = goals['protein']! - loggedProtein;
    final waterDeficit = goals['water']! - loggedWaterL;
    final fiberDeficit = goals['fiber']! - loggedFiber;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meal Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Weekly Analytics Overview'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _AnalyticsOverviewCard(
                  title: 'Most Eaten Food',
                  value: _todayEntries.isEmpty ? '-' : _todayEntries.first.foodName,
                  icon: Icons.favorite_border,
                  color: AppColors.primary,
                ),
                _AnalyticsOverviewCard(
                  title: 'Goal Completion %',
                  value: '${(loggedCalories > 0 ? (loggedCalories / goals['calories']! * 100).clamp(0, 100).round() : 0)}%',
                  icon: Icons.star_border,
                  color: AppColors.primaryBright,
                ),
                _AnalyticsOverviewCard(
                  title: 'Avg Daily Calories',
                  value: '${loggedCalories.toStringAsFixed(0)} kcal',
                  icon: Icons.local_fire_department_outlined,
                  color: AppColors.accent,
                ),
                _AnalyticsOverviewCard(
                  title: 'Avg Daily Protein',
                  value: '${loggedProtein.toStringAsFixed(0)}g',
                  icon: Icons.fitness_center,
                  color: AppColors.accentOrange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Local Nutrition Engine Warnings'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocalWarningRow('Calorie Target', calDeficit, 'kcal remaining to meet your baseline targets.'),
                  const Divider(color: AppColors.border),
                  _buildLocalWarningRow('Protein Deficit', protDeficit, 'g below your calculated growth target.'),
                  const Divider(color: AppColors.border),
                  _buildLocalWarningRow('Water Deficit', waterDeficit, 'L below optimal cellular hydration level.'),
                  const Divider(color: AppColors.border),
                  _buildLocalWarningRow('Fiber Deficit', fiberDeficit, 'g below daily digestional goals.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'AI Coach Nutrition Report'),
            const SizedBox(height: 12),
            if (_isGeneratingReport)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 12),
                      Text('AI Coach is reviewing your meal log...', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              )
            else if (_aiReport != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('AI Nutrition Coach', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 8),
                    Text(
                      _aiReport!,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      const Text(
                        'Unlock deeper insights using the Gemini AI Coach',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      GradientButton(
                        text: 'Analyze with AI',
                        onPressed: _generateAIReport,
                        icon: Icons.psychology_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalWarningRow(String label, double deficit, String description) {
    bool isAlert = deficit > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: isAlert ? AppColors.warning : AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  if (deficit > 0)
                    TextSpan(
                      text: '${deficit.toStringAsFixed(deficit.abs() < 5 ? 1 : 0)} ',
                      style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700),
                    )
                  else
                    const TextSpan(text: 'Goal Met! ', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                  TextSpan(text: isAlert ? description : 'Keep up the consistency.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsOverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _AnalyticsOverviewCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
