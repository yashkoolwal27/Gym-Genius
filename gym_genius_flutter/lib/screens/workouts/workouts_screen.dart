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
  final _firestoreService = FirestoreService();

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
          // Config card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customize Your Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 16),

                // Goal
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

                // Level
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

                // Muscle Groups
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

                // Duration
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

          // Generated Plan
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
      builder: (_) => _LogWorkoutSheet(onSaved: () => setState(() {})),
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

class _LogWorkoutSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _LogWorkoutSheet({required this.onSaved});

  @override
  State<_LogWorkoutSheet> createState() => _LogWorkoutSheetState();
}

class _LogWorkoutSheetState extends State<_LogWorkoutSheet> {
  final _firestoreService = FirestoreService();
  final List<String> _selectedTypes = [];
  final List<Map<String, dynamic>> _exercises = [];
  bool _isSaving = false;

  void _addExercise() {
    setState(() => _exercises.add({
      'id': const Uuid().v4(),
      'name': '',
      'sets': [{'id': const Uuid().v4(), 'reps': '', 'weight': ''}],
    }));
  }

  Future<void> _save() async {
    if (_selectedTypes.isEmpty || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add exercise types and exercises'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isSaving = true);
    final now = DateTime.now();
    final log = WorkoutLog(
      id: const Uuid().v4(),
      date: DateFormat('yyyy-MM-dd').format(now),
      time: DateFormat('HH:mm').format(now),
      exerciseTypes: _selectedTypes,
      exercises: _exercises.map((e) => LoggedExercise(
        id: e['id'],
        name: e['name'],
        sets: (e['sets'] as List).map((s) => WorkoutSet(id: s['id'], reps: s['reps'], weight: s['weight'])).toList(),
      )).toList(),
      createdAt: now.toIso8601String(),
    );
    await _firestoreService.addWorkoutLog(log);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Log Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Exercise Types', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: AppConstants.exerciseTypes.map((t) => _Chip(
                      label: t,
                      selected: _selectedTypes.contains(t),
                      onTap: () => setState(() {
                        _selectedTypes.contains(t) ? _selectedTypes.remove(t) : _selectedTypes.add(t);
                      }),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Exercises', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: _addExercise,
                        icon: const Icon(Icons.add, color: AppColors.primary, size: 16),
                        label: const Text('Add Exercise', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      ),
                    ],
                  ),
                  ..._exercises.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ex = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(hintText: 'Exercise name (e.g. Bench Press)'),
                              onChanged: (v) => _exercises[i]['name'] = v,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    decoration: const InputDecoration(hintText: 'Reps', hintStyle: TextStyle(fontSize: 13)),
                                    onChanged: (v) => (_exercises[i]['sets'] as List)[0]['reps'] = v,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    decoration: const InputDecoration(hintText: 'Weight (kg)', hintStyle: TextStyle(fontSize: 13)),
                                    onChanged: (v) => (_exercises[i]['sets'] as List)[0]['weight'] = v,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Save Workout',
                    onPressed: _isSaving ? null : _save,
                    isLoading: _isSaving,
                    icon: Icons.save_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
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
