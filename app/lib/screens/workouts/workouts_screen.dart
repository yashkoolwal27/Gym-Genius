import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/ai_service.dart';
import '../../widgets/shared_widgets.dart';
import '../../core/exercise_filter_tags.dart';
import 'workout_player_screen.dart';
import '../main_shell.dart';
import 'saved_templates_screen.dart';
import 'workout_history_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workouts & History'),
        centerTitle: false,
      ),
      body: const _WorkoutDashboardTab(),
    );
  }
}

class _WorkoutDashboardTab extends StatefulWidget {
  const _WorkoutDashboardTab();

  @override
  State<_WorkoutDashboardTab> createState() => _WorkoutDashboardTabState();
}

class _WorkoutDashboardTabState extends State<_WorkoutDashboardTab> {
  final _firestoreService = FirestoreService();
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _firestoreService.getUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
      });
    }
  }

  void _showWorkoutPlannerDialog() {
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

  void _navigateToTab(int index) {
    final shellState = context.findAncestorStateOfType<State<MainShell>>();
    if (shellState != null) {
      (shellState as dynamic).setState(() {
        (shellState as dynamic)._selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userProfile?.name ?? 'Athlete';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<WorkoutLog>>(
        stream: _firestoreService.getWorkoutLogsStream(),
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          final nowStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final todayLogs = logs.where((w) => w.date == nowStr).toList();
          
          final workoutsToday = todayLogs.length;
          
          int totalSetsToday = 0;
          for (final w in todayLogs) {
            for (final e in w.exercises) {
              totalSetsToday += e.sets.length;
            }
          }
          final durationToday = totalSetsToday * 3;
          final caloriesToday = durationToday * 6;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Section
                Text(
                  'Good Morning, $userName! 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ready to crush your goals today?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Purple Card / Start Workout Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Start a Workout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Plan your exercises, sets, and reps for today or any other day, and start your session.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _showWorkoutPlannerDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6D28D9),
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Plan & Start Workout',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Summary Row
                const Text(
                  "Today's Summary",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTodayStatCard(
                        title: 'Workouts',
                        value: '$workoutsToday',
                        icon: Icons.fitness_center_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTodayStatCard(
                        title: 'Calories',
                        value: '$caloriesToday kcal',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTodayStatCard(
                        title: 'Duration',
                        value: '$durationToday min',
                        icon: Icons.timer_outlined,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActionRow(
                  icon: Icons.auto_awesome,
                  title: 'AI Workout Generator',
                  subtitle: 'Generate a plan using AI personalization',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIWorkoutGeneratorScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickActionRow(
                  icon: Icons.assignment_outlined,
                  title: 'My Workout Plans',
                  subtitle: 'Select from your saved templates',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedTemplatesScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickActionRow(
                  icon: Icons.history_rounded,
                  title: 'My History',
                  subtitle: 'See your workout logs and history',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkoutHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickActionRow(
                  icon: Icons.show_chart_rounded,
                  title: 'Progress & Analytics',
                  subtitle: 'Track your performance over time',
                  onTap: () => _navigateToTab(2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 12),
          ],
        ),
      ),
    );
  }
}

class AIWorkoutGeneratorScreen extends StatefulWidget {
  const AIWorkoutGeneratorScreen({super.key});

  @override
  State<AIWorkoutGeneratorScreen> createState() => _AIWorkoutGeneratorScreenState();
}

class _AIWorkoutGeneratorScreenState extends State<AIWorkoutGeneratorScreen> {
  final _aiService = AIService();
  final _firestoreService = FirestoreService();

  int _generationMode = 0; // 0: From Profile, 1: Custom
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  final List<String> _selectedMuscles = [];
  int _duration = 45;
  bool _isGenerating = false;
  String? _generatedPlan;
  StructuredWorkoutPlan? _structuredPlan;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _firestoreService.getUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _generate() async {
    if (_generationMode == 1 && _selectedMuscles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one muscle group'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() { _isGenerating = true; _generatedPlan = null; _structuredPlan = null; });
    try {
      String plan;
      if (_generationMode == 0) {
        if (_userProfile == null) throw 'Profile not found. Please complete your profile.';
        plan = await _aiService.generateWorkoutPlanFromProfile(profile: _userProfile!);
      } else {
        plan = await _aiService.generateWorkoutPlan(
          fitnessGoal: _userProfile?.fitnessGoal ?? 'General Fitness',
          experienceLevel: _userProfile?.activityLevel ?? 'Intermediate',
          targetMuscles: _selectedMuscles,
          durationMinutes: _duration,
        );
      }
      
      String cleanPlan = plan.replaceAll('```json', '').replaceAll('```', '').trim();
      final decoded = jsonDecode(cleanPlan);
      final structured = StructuredWorkoutPlan.fromJson(decoded);

      setState(() {
        _generatedPlan = plan;
        _structuredPlan = structured;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _savePlan() async {
    if (_generatedPlan == null) return;
    await _firestoreService.saveWorkoutPlan(StoredPlan(
      id: const Uuid().v4(),
      generatedPlan: _generatedPlan!,
      createdAt: DateTime.now().toIso8601String(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout plan saved! ✅'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Workout Generator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented control or buttons for mode
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _generationMode = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _generationMode == 0 ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Auto (From Profile)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _generationMode == 0 ? AppColors.primary : AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _generationMode = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _generationMode == 1 ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Custom Generate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _generationMode == 1 ? AppColors.primary : AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_generationMode == 0) ...[
              AppCard(
                child: _isLoadingProfile
                    ? const Center(child: CircularProgressIndicator())
                    : _userProfile == null
                        ? const Text('Profile not found. Please complete your profile to use auto-generation.', style: TextStyle(color: AppColors.error))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Profile Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 12),
                              _ProfileDetailRow(icon: Icons.flag, label: 'Goal', value: _userProfile!.fitnessGoal),
                              _ProfileDetailRow(icon: Icons.fitness_center, label: 'Level', value: _userProfile!.activityLevel),
                              _ProfileDetailRow(icon: Icons.height, label: 'Height', value: '${_userProfile!.height.toStringAsFixed(1)} cm'),
                              _ProfileDetailRow(icon: Icons.monitor_weight, label: 'Weight', value: '${_userProfile!.weight.toStringAsFixed(1)} kg'),
                              const SizedBox(height: 16),
                              GradientButton(
                                text: _isGenerating ? 'Generating...' : 'Auto Generate Plan',
                                onPressed: _isGenerating ? null : _generate,
                                isLoading: _isGenerating,
                                icon: Icons.auto_awesome,
                              ),
                            ],
                          ),
              ),
            ] else ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Custom Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    const Text('Target Muscles', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: AppConstants.exerciseTypes.map((m) => _Chip(
                        label: m,
                        selected: _selectedMuscles.contains(m),
                        onTap: () => setState(() {
                          _selectedMuscles.contains(m) ? _selectedMuscles.remove(m) : _selectedMuscles.add(m);
                        }),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('$_duration min', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Slider(
                      value: _duration.toDouble(),
                      min: 15, max: 90, divisions: 5,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                      onChanged: (v) => setState(() => _duration = v.toInt()),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: _isGenerating ? 'Generating...' : 'Generate Custom Plan',
                      onPressed: _isGenerating ? null : _generate,
                      isLoading: _isGenerating,
                      icon: Icons.auto_awesome,
                    ),
                  ],
                ),
              ),
            ],
            if (_structuredPlan != null) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(_structuredPlan!.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.save_outlined, color: AppColors.primary),
                          onPressed: _savePlan,
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 8),
                    ..._structuredPlan!.exercises.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Icon(Icons.fitness_center, color: AppColors.primary, size: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('${e.sets} Sets x ${e.reps}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: 'Start Workout',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutPlayerScreen(plan: _structuredPlan!)));
                      },
                      icon: Icons.play_arrow,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _savePlan,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Save Plan'),
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

class _ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileDetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}



// --- ENHANCED WORKOUT STEPPER (WEBSITE STYLE) ---

class LogWorkoutStepper extends StatefulWidget {
  const LogWorkoutStepper({super.key});

  @override
  State<LogWorkoutStepper> createState() => LogWorkoutStepperState();
}

class LogWorkoutStepperState extends State<LogWorkoutStepper> {
  int _currentStep = 0;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _selectedMuscles = [];
  final List<String> _selectedExercises = [];
  final Map<String, List<WorkoutSet>> _exerciseDetails = {};

  final _firestoreService = FirestoreService();

  // State fields to hold final saved workout stats for the success screen
  int _savedDuration = 0;
  double _savedVolume = 0.0;
  int _savedCalories = 0;
  List<String> _savedMuscles = [];
  List<Map<String, dynamic>> _savedPrs = [];

  // New fields for personalization
  List<Exercise> _allExercises = [];
  UserProfile? _userProfile;
  List<WorkoutLog> _workoutHistory = [];
  bool _isLoadingData = true;
  final Set<String> _activeFilters = {};
  bool _isExerciseGridView = false;

  // Added search, favorites, recents, templates state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<WorkoutTemplate> _workoutTemplates = [];
  Set<String> _favoritedExerciseIds = {};

  final Map<String, String> _muscleImages = {
    'Chest': 'https://cdn.muscleandstrength.com/sites/default/files/machine_press_exercise_for_chest_feature.jpg?w=400&q=80',
    'Back': 'https://i.ytimg.com/vi/JdjJC6eIk44/sddefault.jpg?w=400&q=80',
    'Legs': 'https://hips.hearstapps.com/hmg-prod/images/closeup-of-man-doing-box-jump-exercise-at-gym-royalty-free-image-1610722191.?crop=0.668xw:1.00xh;0.150xw,0&resize=640:*?w=400&q=80',
    'Shoulders': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-sZDah15JjuXBw7z_WfSoHmmggZ3n-9dligBv0hbXnYLd6ui4Wofddlw&s=10?w=400&q=80',
    'Biceps': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRcAuGhshbzpV6PZKnj3lGdJpG991ZD0xajbsXGK2A6YtieNOT-zZZid5EP&s=10?w=400&q=80',
    'Triceps': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxe-tc2WdbAjxGyjguenedpTya49ro0x5aHmjin0EA2w&s=10?w=400&q=80',
    'Abs': 'https://cdn.mypowerlife.com/wp-content/uploads/2021/04/64572607_s.jpg?w=400&q=80',
    'Cardio': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFpdUqEFnnA4AoBJkcrmcJuxlrWqQIFvSubImdAQiG3XB8JY_-9a0RJuOI&s=10?w=400&q=80',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final profile = await _firestoreService.getUserProfile();
      final exercises = await _firestoreService.getExercises();
      final logs = await _firestoreService.getWorkoutLogs();
      final favs = await _firestoreService.getFavoriteExercises();
      final templates = await _firestoreService.getWorkoutTemplates();
      setState(() {
        _userProfile = profile;
        _allExercises = exercises;
        _workoutHistory = logs;
        _favoritedExerciseIds = favs.toSet();
        _workoutTemplates = templates;
        _isLoadingData = false;
      });
    } catch (_) {
      setState(() => _isLoadingData = false);
    }
  }

  int _scoreExercise(Exercise exercise) {
    if (_userProfile == null) return 0;
    int score = 0;

    final primary = _userProfile!.primaryTrainingStyle.toLowerCase();
    final secondary = _userProfile!.secondaryTrainingStyle.toLowerCase();
    final fitnessGoal = _userProfile!.fitnessGoal.toLowerCase();
    final level = _userProfile!.fitnessLevel.toLowerCase();
    final equip = _userProfile!.availableEquipment.map((e) => e.toLowerCase()).toList();

    // 1. Primary Style Match (+70)
    if (exercise.trainingStyles.any((c) => c.toLowerCase() == primary)) {
      score += 70;
    }

    // 2. Secondary Style Match (+30)
    if (secondary != 'none' && exercise.trainingStyles.any((c) => c.toLowerCase() == secondary)) {
      score += 30;
    }

    // 3. Goal based scoring (+20)
    if (exercise.trainingStyles.any((c) => c.toLowerCase() == fitnessGoal) || 
        exercise.goalTags.any((t) => t.toLowerCase() == fitnessGoal)) {
      score += 20;
    }

    // 4. Difficulty Match (+10)
    if (exercise.difficulty.toLowerCase() == level) {
      score += 10;
    }

    // 5. Equipment Availability: Available (+10), Missing (-50)
    final hasEquipment = exercise.equipment.isEmpty || 
        exercise.equipment.any((reqEquip) => equip.contains(reqEquip.toLowerCase()) || reqEquip.toLowerCase() == 'bodyweight');
    if (hasEquipment) {
      score += 10;
    } else {
      score -= 50;
    }

    return score;
  }

  Exercise? _getExerciseByName(String name) {
    try {
      return _allExercises.firstWhere((e) => e.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  List<Exercise> _getRecentlyUsedExercises() {
    final List<String> recentNames = [];
    for (final log in _workoutHistory) {
      for (final ex in log.exercises) {
        if (!recentNames.contains(ex.name)) {
          recentNames.add(ex.name);
        }
        if (recentNames.length >= 8) break;
      }
      if (recentNames.length >= 8) break;
    }
    return recentNames
        .map((name) => _getExerciseByName(name))
        .whereType<Exercise>()
        .toList();
  }

  void _showSaveTemplateDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('Save Workout Template'),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'e.g., Push Day, Chest & Tri Split',
              hintStyle: TextStyle(color: AppColors.textMuted),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                
                final template = WorkoutTemplate(
                  id: '',
                  name: name,
                  exerciseNames: _selectedExercises,
                  muscleGroups: _selectedMuscles,
                );
                
                await _firestoreService.saveWorkoutTemplate(template);
                
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template "$name" saved! ✅'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadData(); // Refresh templates list
                }
              },
              child: const Text('Save', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  Map<String, double> _getMuscleRecoveryHours() {
    final Map<String, double> recoveryHours = {};
    for (final log in _workoutHistory) {
      try {
        final logTime = DateTime.tryParse(log.createdAt) ?? 
                        DateFormat('yyyy-MM-dd HH:mm').parse('${log.date} ${log.time}');
        final diffHours = DateTime.now().difference(logTime).inHours.toDouble();
        for (final muscle in log.exerciseTypes) {
          if (!recoveryHours.containsKey(muscle) || diffHours < recoveryHours[muscle]!) {
            recoveryHours[muscle] = diffHours;
          }
        }
      } catch (_) {}
    }
    return recoveryHours;
  }

  bool _isMuscleRecovering(String muscle, double hoursElapsed) {
    if (muscle == 'Chest' || muscle == 'Shoulders' || muscle == 'Biceps' || muscle == 'Triceps') {
      return hoursElapsed < 48;
    } else if (muscle == 'Back' || muscle == 'Legs') {
      return hoursElapsed < 72;
    } else if (muscle == 'Abs') {
      return hoursElapsed < 24;
    }
    return false;
  }

  double _getRequiredRecoveryWindow(String muscle) {
    if (muscle == 'Chest' || muscle == 'Shoulders' || muscle == 'Biceps' || muscle == 'Triceps') {
      return 48;
    } else if (muscle == 'Back' || muscle == 'Legs') {
      return 72;
    } else if (muscle == 'Abs') {
      return 24;
    }
    return 24;
  }

  void _nextStep() {
    if (_currentStep == 1 && _selectedMuscles.isEmpty) return;
    if (_currentStep == 2 && _selectedExercises.isEmpty) return;
    setState(() => _currentStep++);
  }

  void _startWorkout() {
    final plan = StructuredWorkoutPlan(
      title: 'Custom Workout (${_selectedMuscles.join(", ")})',
      exercises: _selectedExercises.map((name) {
        final setsList = _exerciseDetails[name] ?? [];
        final firstReps = setsList.isNotEmpty && setsList.first.reps.isNotEmpty ? setsList.first.reps : '10';
        final firstWeight = setsList.isNotEmpty && setsList.first.weight.isNotEmpty ? '${setsList.first.weight} kg' : '';
        final exObj = _getExerciseByName(name);
        return WorkoutExercise(
          category: exObj?.muscleGroup ?? (_selectedMuscles.isNotEmpty ? _selectedMuscles.first : 'General'),
          name: name,
          sets: setsList.length,
          reps: firstReps,
          weightRecommendation: firstWeight,
          restBetweenSetsSeconds: 60,
          restAfterExerciseSeconds: 120,
          tipsOrGoal: '',
        );
      }).toList(),
    );
    Navigator.pop(context); // Close the bottom sheet planner stepper
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutPlayerScreen(plan: plan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),

          // Stepper Header (Only shown for Steps 0-4, hidden on Success Screen Step 5)
          if (_currentStep < 5) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary),
                      onPressed: () => setState(() => _currentStep--),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _getStepTitle(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Step ${_currentStep + 1} of 5',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 5,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep0_DateTime(),
                _buildStep1_Muscles(),
                _buildStep2_Exercises(),
                _buildStep3_Details(),
                _buildStep4_Review(),
                _buildStep5_Success(
                  duration: _savedDuration,
                  totalVolume: _savedVolume,
                  estimatedCalories: _savedCalories,
                  musclesTrained: _savedMuscles,
                  prList: _savedPrs,
                ),
              ],
            ),
          ),

          // Action Button (Only shown for steps < 5)
          if (_currentStep < 5)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: _currentStep == 4
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientButton(
                          text: 'Start Workout',
                          onPressed: _startWorkout,
                          icon: Icons.play_arrow_rounded,
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _showSaveTemplateDialog,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Save as Template'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    )
                  : GradientButton(
                      text: 'Next Step',
                      onPressed: _nextStep,
                      icon: Icons.arrow_forward_ios_rounded,
                    ),
            ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Select Date & Time';
      case 1: return 'Select Muscle Groups';
      case 2: return 'Select Your Exercises';
      case 3: return 'Set Plan Details';
      case 4: return 'Review Workout Plan';
      case 5: return 'Workout Logged';
      default: return 'Workout Planner';
    }
  }

  Widget _buildStep4_Review() {
    int totalSets = 0;
    for (final ex in _selectedExercises) {
      totalSets += (_exerciseDetails[ex] ?? []).length;
    }
    final formattedTime = _selectedTime.format(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout Overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                _buildReviewRow(Icons.calendar_today_rounded, 'Date & Time', '${DateFormat('yyyy-MM-dd').format(_selectedDate)} @ $formattedTime'),
                const Divider(color: AppColors.border, height: 24),
                _buildReviewRow(Icons.accessibility_new_rounded, 'Muscle Groups', _selectedMuscles.join(', ')),
                const Divider(color: AppColors.border, height: 24),
                _buildReviewRow(Icons.fitness_center_rounded, 'Exercises', '${_selectedExercises.length} Exercises'),
                const Divider(color: AppColors.border, height: 24),
                _buildReviewRow(Icons.format_list_bulleted_rounded, 'Total Sets', '$totalSets Sets'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Exercises Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ..._selectedExercises.map((exName) {
            final sets = _exerciseDetails[exName] ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${sets.length} sets',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep5_Success({
    required int duration,
    required double totalVolume,
    required int estimatedCalories,
    required List<String> musclesTrained,
    required List<Map<String, dynamic>> prList,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.check_circle_rounded, size: 48, color: Colors.green),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Workout Logged!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Great job! Your workout has been saved.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStatCard(
                  title: 'Duration',
                  value: '${(duration ~/ 60).toString().padLeft(2, '0')}:${(duration % 60).toString().padLeft(2, '0')}:00',
                  icon: Icons.timer_outlined,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStatCard(
                  title: 'Total Sets',
                  value: '${_getTotalSetsCount()}',
                  icon: Icons.format_list_bulleted_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStatCard(
                  title: 'Calories Burned',
                  value: '$estimatedCalories kcal',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStatCard(
                  title: 'Volume',
                  value: '${totalVolume.toStringAsFixed(0)} kg',
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (prList.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '⭐ New Personal Records!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 10),
            ...prList.map((pr) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pr['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  Text(
                    '${pr['weight']} kg',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 15),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 16),
          GradientButton(
            text: 'View Workout',
            onPressed: () {
              Navigator.pop(context);
              _navigateToTab(context, 1);
            },
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToTab(context, 0);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  int _getTotalSetsCount() {
    int count = 0;
    for (final ex in _selectedExercises) {
      count += (_exerciseDetails[ex] ?? []).length;
    }
    return count;
  }

  void _navigateToTab(BuildContext context, int index) {
    final shellState = context.findAncestorStateOfType<State<MainShell>>();
    if (shellState != null) {
      (shellState as dynamic).setState(() {
        (shellState as dynamic)._selectedIndex = index;
      });
    }
  }

  Widget _buildStep0_DateTime() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              onDateChanged: (d) => setState(() => _selectedDate = d),
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _selectedTime);
              if (time != null) setState(() => _selectedTime = time);
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.access_time_filled_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Workout Time', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(_selectedTime.format(context), style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1_Muscles() {
    final List<String> muscleList = ['Chest', 'Back', 'Legs', 'Shoulders', 'Biceps', 'Triceps', 'Abs', 'Cardio'];
    final recoveryData = _getMuscleRecoveryHours();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_workoutTemplates.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Workout Templates 📋',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _workoutTemplates.length,
                itemBuilder: (context, index) {
                  final template = _workoutTemplates[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMuscles.clear();
                          _selectedMuscles.addAll(template.muscleGroups);
                          _selectedExercises.clear();
                          _selectedExercises.addAll(template.exerciseNames);
                          for (final name in template.exerciseNames) {
                            if (!_exerciseDetails.containsKey(name)) {
                              _exerciseDetails[name] = [
                                WorkoutSet(id: const Uuid().v4(), reps: '', weight: '')
                              ];
                            }
                          }
                          _currentStep = 3; // Jump directly to Step 3
                        });
                      },
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    template.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: this.context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppColors.cardBg,
                                        title: const Text('Delete Template'),
                                        content: Text('Are you sure you want to delete "${template.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _firestoreService.deleteWorkoutTemplate(template.id);
                                      _loadData(); // Reload templates
                                    }
                                  },
                                  child: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 16),
                                ),
                              ],
                            ),
                            Text(
                              '${template.exerciseNames.length} exercises',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              template.muscleGroups.join(', '),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Select Muscle Groups',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: muscleList.length,
            itemBuilder: (context, index) {
              final muscle = muscleList[index];
              final isSelected = _selectedMuscles.contains(muscle);
              
              bool isRecovering = false;
              if (recoveryData.containsKey(muscle)) {
                isRecovering = _isMuscleRecovering(muscle, recoveryData[muscle]!);
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected ? _selectedMuscles.remove(muscle) : _selectedMuscles.add(muscle);
                  });
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
                    boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10)] : null,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.network(
                              _muscleImages[muscle]!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.border, child: const Icon(Icons.fitness_center)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                            child: Text(
                              muscle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isRecovering)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 10),
                                SizedBox(width: 3),
                                Text(
                                  'Rest',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryWarningBanner() {
    final recoveryData = _getMuscleRecoveryHours();
    final List<String> recoveringMuscles = [];

    for (final muscle in _selectedMuscles) {
      if (recoveryData.containsKey(muscle)) {
        final hours = recoveryData[muscle]!;
        if (_isMuscleRecovering(muscle, hours)) {
          final requiredHours = _getRequiredRecoveryWindow(muscle);
          recoveringMuscles.add('$muscle (${hours.toInt()}h trained / needs ${requiredHours.toInt()}h)');
        }
      }
    }

    if (recoveringMuscles.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Muscle Recovery Warning ⚠️',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error),
                ),
                const SizedBox(height: 4),
                Text(
                  'The following muscles were trained recently: ${recoveringMuscles.join(", ")}.',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2_Exercises() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final filteredExercises = _allExercises.where((ex) {
      if (_searchQuery.isNotEmpty) {
        return ex.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return _selectedMuscles.contains(ex.muscleGroup);
    }).toList();

    List<Exercise> displayExercises = filteredExercises;
    if (_activeFilters.isNotEmpty) {
      displayExercises = displayExercises.where((ex) {
        return _activeFilters.every((filt) {
          if (filt == 'Favorites') {
            return _favoritedExerciseIds.contains(ex.exerciseId);
          }
          return ex.tags.any((t) => t.toLowerCase() == filt.toLowerCase()) ||
              ex.difficulty.toLowerCase() == filt.toLowerCase() ||
              ex.equipment.any((e) => e.toLowerCase() == filt.toLowerCase()) ||
              ex.targetRegions.any((r) => r.toLowerCase() == filt.toLowerCase());
        });
      }).toList();
    }

    // Sort based on score
    displayExercises.sort((a, b) => _scoreExercise(b).compareTo(_scoreExercise(a)));

    final recommended = displayExercises.where((ex) => _scoreExercise(ex) > 0).toList();
    final other = displayExercises.where((ex) => _scoreExercise(ex) <= 0).toList();

    final activeMuscleGroup = _selectedMuscles.isNotEmpty ? _selectedMuscles.first : 'Chest';
    final List<String> groupFilters = ExerciseFilterTags.getFiltersForMuscleGroup(activeMuscleGroup);

    return Column(
      children: [
        // Search bar & Grid/List toggle row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.cardBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    setState(() => _searchQuery = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isExerciseGridView
                        ? Icons.format_list_bulleted_rounded
                        : Icons.grid_view_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExerciseGridView = !_isExerciseGridView;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Equipment filter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: groupFilters.map((filt) {
              final isSel = filt == 'All'
                  ? _activeFilters.isEmpty
                  : _activeFilters.contains(filt);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filt),
                  selected: isSel,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.cardBg,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (filt == 'All') {
                        _activeFilters.clear();
                      } else {
                        if (selected) {
                          _activeFilters.add(filt);
                        } else {
                          _activeFilters.remove(filt);
                        }
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Save Selection as Template Option
        if (_selectedExercises.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: AppCard(
              onTap: _showSaveTemplateDialog,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.save_as_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save Selection as Template',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Reuse this exact combination next time',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),

        // Warning banner for recovery
        _buildRecoveryWarningBanner(),

        // Exercises list
        Expanded(
          child: displayExercises.isEmpty
              ? const EmptyState(
                  icon: Icons.fitness_center_rounded,
                  title: 'No Exercises Found',
                  subtitle: 'Try changing your filters or search query.',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Recently Used Row
                    () {
                      final recentList = _getRecentlyUsedExercises();
                      if (recentList.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.history, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Recently Used 🕒',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: recentList.map((ex) {
                                final isSelected = _selectedExercises.contains(ex.name);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedExercises.remove(ex.name);
                                        } else {
                                          _selectedExercises.add(ex.name);
                                          if (!_exerciseDetails.containsKey(ex.name)) {
                                            _exerciseDetails[ex.name] = [
                                              WorkoutSet(id: const Uuid().v4(), reps: '', weight: '')
                                            ];
                                          }
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.cardBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            ex.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }(),

                    if (recommended.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Recommended For You ⭐',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isExerciseGridView)
                        _buildExerciseGrid(recommended)
                      else
                        ...recommended.map((ex) => _buildExerciseTile(ex)),
                      const SizedBox(height: 16),
                    ],
                    if (other.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'All Exercises',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_isExerciseGridView)
                        _buildExerciseGrid(other)
                      else
                        ...other.map((ex) => _buildExerciseTile(ex)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildExerciseGrid(List<Exercise> exercises) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final ex = exercises[index];
        final isSelected = _selectedExercises.contains(ex.name);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedExercises.remove(ex.name);
              } else {
                _selectedExercises.add(ex.name);
                if (!_exerciseDetails.containsKey(ex.name)) {
                  _exerciseDetails[ex.name] = [
                    WorkoutSet(id: const Uuid().v4(), reps: '', weight: '')
                  ];
                }
              }
            });
          },
          onLongPress: () => _showExerciseDetails(ex),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accentPurple : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        child: ex.thumbnail.isNotEmpty
                            ? Image.network(
                                ex.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.background,
                                  child: const Icon(Icons.image_outlined, size: 20, color: AppColors.textMuted),
                                ),
                              )
                            : Container(
                                color: AppColors.background,
                                child: const Icon(Icons.fitness_center_rounded, size: 20, color: AppColors.textMuted),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ex.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.accentPurple : AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ex.equipment.join(', '),
                              style: const TextStyle(
                                fontSize: 8,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: isSelected
                      ? Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.accentPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 10),
                        )
                      : Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 1.2),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseTile(Exercise ex) {
    final isSelected = _selectedExercises.contains(ex.name);
    final isFav = _favoritedExerciseIds.contains(ex.exerciseId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedExercises.remove(ex.name);
            } else {
              _selectedExercises.add(ex.name);
              if (!_exerciseDetails.containsKey(ex.name)) {
                _exerciseDetails[ex.name] = [
                  WorkoutSet(id: const Uuid().v4(), reps: '', weight: '')
                ];
              }
            }
          });
        },
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail / fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: ex.thumbnail.isNotEmpty
                    ? Image.network(
                        ex.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.border,
                          child: const Icon(Icons.image_outlined, size: 20, color: AppColors.textMuted),
                        ),
                      )
                    : Container(
                        color: AppColors.border,
                        child: const Icon(Icons.fitness_center_rounded, size: 20, color: AppColors.textMuted),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...ex.targetRegions.map((region) => _buildCardChip(region, Colors.teal)),
                      ...ex.equipment.map((eq) => _buildCardChip(eq, Colors.indigo)),
                      _buildCardChip(ex.difficulty, Colors.amber),
                      _buildCardChip(ex.isCompound ? 'Compound' : 'Isolation', Colors.deepPurple),
                      _buildCardChip('Score: ${_scoreExercise(ex)}', AppColors.primary, isHighlight: true),
                    ],
                  ),
                ],
              ),
            ),
            // Star Icon
            IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav ? AppColors.primary : AppColors.textMuted,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  if (isFav) {
                    _favoritedExerciseIds.remove(ex.exerciseId);
                  } else {
                    _favoritedExerciseIds.add(ex.exerciseId);
                  }
                });
                _firestoreService.toggleFavoriteExercise(ex.exerciseId, !isFav);
              },
            ),
            // Info Icon
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
              onPressed: () => _showExerciseDetails(ex),
            ),
            // Checkmark
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardChip(String text, Color color, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHighlight ? color.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: isHighlight ? Border.all(color: color.withOpacity(0.5), width: 0.8) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showExerciseDetails(Exercise ex) {
    // Find alternative exercises
    final List<Exercise> altExercises = [];
    for (final altId in ex.alternatives) {
      try {
        final found = _allExercises.firstWhere((e) => e.exerciseId == altId);
        altExercises.add(found);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ex.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Tags Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDetailTag(ex.difficulty, Colors.green),
                      ...ex.equipment.map((e) => _buildDetailTag(e, Colors.blue)),
                      _buildDetailTag(ex.muscleGroup, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Alternatives & Substitution Section
                  if (altExercises.isNotEmpty) ...[
                    const Text('Alternatives & Substitution 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap an alternative below to swap this exercise in your workout.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: altExercises.length,
                        itemBuilder: (context, idx) {
                          final altEx = altExercises[idx];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                final oldName = ex.name;
                                final newName = altEx.name;
                                
                                setState(() {
                                  // Replace in _selectedExercises
                                  final index = _selectedExercises.indexOf(oldName);
                                  if (index != -1) {
                                    _selectedExercises[index] = newName;
                                  } else {
                                    _selectedExercises.add(newName);
                                  }
                                  
                                  // Move sets detail
                                  final oldSets = _exerciseDetails[oldName];
                                  if (oldSets != null) {
                                    _exerciseDetails[newName] = oldSets;
                                    _exerciseDetails.remove(oldName);
                                  } else {
                                    _exerciseDetails[newName] = [
                                      WorkoutSet(id: const Uuid().v4(), reps: '', weight: '')
                                    ];
                                  }
                                });
                                
                                Navigator.pop(context); // Close details bottom sheet
                                
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text('Substituted "$oldName" with "$newName"! 🔄'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              child: Container(
                                width: 180,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: SizedBox(
                                        width: 36, height: 36,
                                        child: altEx.thumbnail.isNotEmpty
                                            ? Image.network(altEx.thumbnail, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.border))
                                            : Container(color: AppColors.border, child: const Icon(Icons.fitness_center, size: 16)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            altEx.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textPrimary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            altEx.difficulty,
                                            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Image / GIF
                  if (ex.thumbnail.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Image.network(
                          ex.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image, size: 40, color: AppColors.textMuted)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Muscles targeted
                  if (ex.primaryMuscles.isNotEmpty) ...[
                    const Text('Primary Muscles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ex.primaryMuscles.map((m) => _buildDetailTag(m, AppColors.primary, isOutline: true)).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (ex.secondaryMuscles.isNotEmpty) ...[
                    const Text('Secondary Muscles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ex.secondaryMuscles.map((m) => _buildDetailTag(m, AppColors.textSecondary, isOutline: true)).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Extra Architectural Metadata
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (ex.targetRegions.isNotEmpty)
                        ...ex.targetRegions.map((region) => _buildDetailTag('Region: $region', Colors.teal)),
                      if (ex.forceType.isNotEmpty)
                        _buildDetailTag('Force: ${ex.forceType}', Colors.indigo),
                      if (ex.mechanics.isNotEmpty)
                        _buildDetailTag('Mechanics: ${ex.mechanics}', Colors.purple),
                      if (ex.bodyRegion.isNotEmpty)
                        _buildDetailTag('Region: ${ex.bodyRegion}', Colors.deepOrange),
                      if (ex.exerciseType.isNotEmpty)
                        _buildDetailTag('Type: ${ex.exerciseType}', Colors.pink),
                      if (ex.movementPattern.isNotEmpty)
                        _buildDetailTag('Pattern: ${ex.movementPattern}', Colors.cyan),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (ex.breathing.isNotEmpty) ...[
                    const Text('Breathing Pattern 🫁', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(ex.breathing, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                    const SizedBox(height: 20),
                  ],

                  if (ex.commonMistakes.isNotEmpty) ...[
                    const Text('Common Mistakes ⚠️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    ...ex.commonMistakes.map((mistake) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.close_rounded, color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(mistake, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],

                  if (ex.safetyTips.isNotEmpty) ...[
                    const Text('Safety Tips 🛡️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    ...ex.safetyTips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],

                  if (ex.progressions.isNotEmpty) ...[
                    const Text('Progressions 📈', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(ex.progressions.join(' → '), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                  ],

                  if (ex.regressions.isNotEmpty) ...[
                    const Text('Regressions 📉', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(ex.regressions.join(' ← '), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                  ],

                  // How to perform steps
                  const Text('How to Perform', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ...ex.steps.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24, height: 24,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailTag(String label, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.15),
        border: isOutline ? Border.all(color: color.withOpacity(0.4)) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStep3_Details() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _selectedExercises.length,
      itemBuilder: (context, index) {
        final ex = _selectedExercises[index];
        final sets = _exerciseDetails[ex] ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(ex, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 20),
                        onPressed: () {
                          final exObj = _getExerciseByName(ex);
                          if (exObj != null) {
                            _showExerciseDetails(exObj);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error, size: 20),
                        onPressed: () => setState(() => _selectedExercises.remove(ex)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...sets.asMap().entries.map((setEntry) {
                final setIdx = setEntry.key;
                final set = setEntry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30, height: 30,
                            decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                            child: Center(child: Text('${setIdx + 1}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Reps',
                                filled: true,
                                fillColor: AppColors.cardBg,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (v) => set.reps = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Weight',
                                suffixText: 'kg',
                                filled: true,
                                fillColor: AppColors.cardBg,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (v) => set.weight = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'RPE (1-10)',
                                filled: true,
                                fillColor: AppColors.cardBg,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (v) => set.rpe = v,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.textMuted, size: 20),
                            onPressed: () => setState(() => sets.removeAt(setIdx)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 42, right: 30),
                        child: TextField(
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Add notes for this set...',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.cardBg,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          onChanged: (v) => set.notes = v,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => sets.add(WorkoutSet(id: const Uuid().v4(), reps: '', weight: '')));
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Set'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const Divider(height: 40, color: AppColors.border),
            ],
          ),
        );
      },
    );
  }



  Widget _buildSummaryStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.2) : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
