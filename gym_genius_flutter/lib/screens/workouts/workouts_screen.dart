import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/ai_service.dart';
import '../../widgets/shared_widgets.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workouts & History'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'AI Generator'),
            Tab(text: 'My History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WorkoutGeneratorTab(),
          _WorkoutHistoryTab(),
        ],
      ),
    );
  }
}

class _WorkoutGeneratorTab extends StatefulWidget {
  const _WorkoutGeneratorTab();

  @override
  State<_WorkoutGeneratorTab> createState() => _WorkoutGeneratorTabState();
}

class _WorkoutGeneratorTabState extends State<_WorkoutGeneratorTab> {
  final _aiService = AIService();
  final _firestoreService = FirestoreService();

  String _fitnessGoal = 'Weight Loss';
  String _experienceLevel = 'Beginner';
  final List<String> _selectedMuscles = [];
  int _duration = 45;
  bool _isGenerating = false;
  String? _generatedPlan;

  final _goals = ['Weight Loss', 'Muscle Gain', 'Endurance', 'Flexibility', 'Maintenance'];
  final _levels = ['Beginner', 'Intermediate', 'Advanced'];

  Future<void> _generate() async {
    if (_selectedMuscles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one muscle group'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() { _isGenerating = true; _generatedPlan = null; });
    try {
      final plan = await _aiService.generateWorkoutPlan(
        fitnessGoal: _fitnessGoal,
        experienceLevel: _experienceLevel,
        targetMuscles: _selectedMuscles,
        durationMinutes: _duration,
      );
      setState(() => _generatedPlan = plan);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customize Your Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                const Text('Fitness Goal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _goals.map((g) => _Chip(
                    label: g,
                    selected: _fitnessGoal == g,
                    onTap: () => setState(() => _fitnessGoal = g),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Experience Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: _levels.map((l) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _Chip(label: l, selected: _experienceLevel == l, onTap: () => setState(() => _experienceLevel = l)),
                    ),
                  )).toList(),
                ),
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
                const SizedBox(height: 8),
                GradientButton(
                  text: _isGenerating ? 'Generating...' : 'Generate Workout Plan',
                  onPressed: _isGenerating ? null : _generate,
                  isLoading: _isGenerating,
                  icon: Icons.auto_awesome,
                ),
              ],
            ),
          ),
          if (_generatedPlan != null) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Workout Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      IconButton(
                        icon: const Icon(Icons.save_outlined, color: AppColors.primary),
                        onPressed: _savePlan,
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  Text(
                    _generatedPlan!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _savePlan,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Save Plan'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkoutHistoryTab extends StatefulWidget {
  const _WorkoutHistoryTab();

  @override
  State<_WorkoutHistoryTab> createState() => _WorkoutHistoryTabState();
}

class _WorkoutHistoryTabState extends State<_WorkoutHistoryTab> {
  final _firestoreService = FirestoreService();

  void _showLogWorkoutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _LogWorkoutStepper(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogWorkoutDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Log Workout', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<WorkoutLog>>(
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
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const EmptyState(
              icon: Icons.fitness_center,
              title: 'No workouts logged',
              subtitle: 'Tap the button below to log your first workout!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: logs.length,
            itemBuilder: (_, i) => _WorkoutHistoryCard(log: logs[i], onDelete: () {
              _firestoreService.deleteWorkoutLog(logs[i].id);
            }),
          );
        },
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

// --- ENHANCED WORKOUT STEPPER (WEBSITE STYLE) ---

class _LogWorkoutStepper extends StatefulWidget {
  const _LogWorkoutStepper();

  @override
  State<_LogWorkoutStepper> createState() => _LogWorkoutStepperState();
}

class _LogWorkoutStepperState extends State<_LogWorkoutStepper> {
  int _currentStep = 0;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _selectedMuscles = [];
  final List<String> _selectedExercises = [];
  final Map<String, List<WorkoutSet>> _exerciseDetails = {};

  final _firestoreService = FirestoreService();
  bool _isSaving = false;

  final Map<String, String> _muscleImages = {
    'Chest': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&q=80',
    'Back': 'https://images.unsplash.com/photo-1603287611837-f214690781d6?w=400&q=80',
    'Legs': 'https://images.unsplash.com/photo-1434608519344-49d77a699e1d?w=400&q=80',
    'Shoulders': 'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=400&q=80',
    'Biceps': 'https://images.unsplash.com/photo-1581009146145-b5ef03a726ec?w=400&q=80',
    'Triceps': 'https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?w=400&q=80',
    'Abs': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80',
    'Cardio': 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=400&q=80',
  };

  final Map<String, List<String>> _muscleToExercises = {
    'Chest': ['Bench Press', 'Incline Dumbbell Press', 'Chest Flys', 'Pushups'],
    'Back': ['Pullups', 'Deadlifts', 'Bent Over Rows', 'Lat Pulldowns'],
    'Legs': ['Squats', 'Leg Press', 'Lunges', 'Calf Raises'],
    'Shoulders': ['Overhead Press', 'Lateral Raises', 'Front Raises'],
    'Biceps': ['Barbell Curls', 'Hammer Curls', 'Preacher Curls'],
    'Triceps': ['Dips', 'Tricep Pushdowns', 'Skull Crushers'],
    'Abs': ['Crunches', 'Plank', 'Leg Raises'],
    'Cardio': ['Running', 'Cycling', 'Swimming', 'Jump Rope'],
  };

  void _nextStep() {
    if (_currentStep == 1 && _selectedMuscles.isEmpty) return;
    if (_currentStep == 2 && _selectedExercises.isEmpty) return;
    setState(() => _currentStep++);
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

          // Stepper Header
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
                        'Step ${_currentStep + 1} of 4',
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
                value: (_currentStep + 1) / 4,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep0_DateTime(),
                _buildStep1_Muscles(),
                _buildStep2_Exercises(),
                _buildStep3_Details(),
              ],
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: _currentStep == 3
                ? GradientButton(
                    text: 'Finish & Log Workout',
                    onPressed: _isSaving ? null : _saveWorkout,
                    isLoading: _isSaving,
                    icon: Icons.check_circle_outline_rounded,
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
      case 1: return 'Log Your Workout';
      case 2: return 'Select Your Exercises';
      case 3: return 'Log Your Details';
      default: return 'Log Workout';
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
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _muscleToExercises.keys.length,
      itemBuilder: (context, index) {
        final muscle = _muscleToExercises.keys.elementAt(index);
        final isSelected = _selectedMuscles.contains(muscle);
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
            child: Column(
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
          ),
        );
      },
    );
  }

  Widget _buildStep2_Exercises() {
    final availableExercises = <String>[];
    for (var muscle in _selectedMuscles) {
      availableExercises.addAll(_muscleToExercises[muscle] ?? []);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: availableExercises.length,
      itemBuilder: (context, index) {
        final ex = availableExercises[index];
        final isSelected = _selectedExercises.contains(ex);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? _selectedExercises.remove(ex) : _selectedExercises.add(ex);
              if (!isSelected) {
                _exerciseDetails[ex] = [WorkoutSet(id: const Uuid().v4(), reps: '', weight: '')];
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ex,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                  ),
              ],
            ),
          ),
        );
      },
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
                  Text(ex, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error, size: 20),
                    onPressed: () => setState(() => _selectedExercises.remove(ex)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...sets.asMap().entries.map((setEntry) {
                final setIdx = setEntry.key;
                final set = setEntry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
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
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Reps',
                            filled: true,
                            fillColor: AppColors.cardBg,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (v) => set.reps = v,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Weight',
                            suffixText: 'kg',
                            filled: true,
                            fillColor: AppColors.cardBg,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (v) => set.weight = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.textMuted, size: 20),
                        onPressed: () => setState(() => sets.removeAt(setIdx)),
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

  Future<void> _saveWorkout() async {
    setState(() => _isSaving = true);
    try {
      final log = WorkoutLog(
        id: const Uuid().v4(),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        time: _selectedTime.format(context),
        exerciseTypes: _selectedMuscles,
        exercises: _selectedExercises.map((name) => LoggedExercise(
          id: const Uuid().v4(),
          name: name,
          sets: _exerciseDetails[name] ?? [WorkoutSet(id: const Uuid().v4(), reps: '0', weight: '0')],
        )).toList(),
        createdAt: DateTime.now().toIso8601String(),
      );
      await _firestoreService.addWorkoutLog(log);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
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
