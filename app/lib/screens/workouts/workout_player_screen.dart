import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final StructuredWorkoutPlan plan;

  const WorkoutPlayerScreen({super.key, required this.plan});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen>
    with TickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _timeRemaining = 0;
  int _totalRestDuration = 0;
  Timer? _timer;
  final Stopwatch _workoutStopwatch = Stopwatch();

  // Audio
  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _dingPlayer = AudioPlayer();
  final AudioPlayer _cheerPlayer = AudioPlayer();

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Firestore
  final FirestoreService _firestoreService = FirestoreService();

  // Track completed exercises for logging
  final List<Map<String, dynamic>> _completedExercises = [];

  @override
  void initState() {
    super.initState();
    _workoutStopwatch.start();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workoutStopwatch.stop();
    _pulseController.dispose();
    _tickPlayer.dispose();
    _dingPlayer.dispose();
    _cheerPlayer.dispose();
    super.dispose();
  }

  // ─── Audio helpers ───
  Future<void> _playTick() async {
    try {
      await _tickPlayer.play(AssetSource('audio/td_tick.mp3'), volume: 0.5);
    } catch (_) {}
  }

  Future<void> _playDing() async {
    try {
      await _dingPlayer.play(AssetSource('audio/td_ding.mp3'));
    } catch (_) {}
  }

  Future<void> _playCheer() async {
    try {
      await _cheerPlayer.play(AssetSource('audio/cheer.mp3'));
    } catch (_) {}
  }

  // ─── Rest Timer ───
  void _startRest(int seconds) {
    setState(() {
      _isResting = true;
      _timeRemaining = seconds;
      _totalRestDuration = seconds;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
        // Tick sound for last 3 seconds
        if (_timeRemaining <= 3 && _timeRemaining > 0) {
          _playTick();
          HapticFeedback.lightImpact();
        }
      } else {
        _playDing();
        HapticFeedback.heavyImpact();
        _skipRest();
      }
    });
  }

  void _addRestTime(int seconds) {
    setState(() {
      _timeRemaining += seconds;
      _totalRestDuration += seconds;
    });
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _isResting = false;
      _timeRemaining = 0;
    });
  }

  // ─── Set / Exercise Progression ───
  void _finishSet() {
    HapticFeedback.mediumImpact();
    final exercise = widget.plan.exercises[_currentExerciseIndex];

    if (_currentSet < exercise.sets) {
      setState(() {
        _currentSet++;
      });
      _startRest(exercise.restBetweenSetsSeconds);
    } else {
      // Log this exercise as completed
      _completedExercises.add({
        'name': exercise.name,
        'category': exercise.category,
        'sets': exercise.sets,
        'reps': exercise.reps,
      });

      if (_currentExerciseIndex < widget.plan.exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
          _currentSet = 1;
        });
        _startRest(exercise.restAfterExerciseSeconds);
      } else {
        _showWorkoutComplete();
      }
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      _timer?.cancel();
      setState(() {
        _currentExerciseIndex--;
        _currentSet = 1;
        _isResting = false;
      });
    }
  }

  void _nextExercise() {
    _timer?.cancel();
    if (_currentExerciseIndex < widget.plan.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _isResting = false;
      });
    } else {
      _showWorkoutComplete();
    }
  }

  // ─── Workout Complete ───
  Future<void> _showWorkoutComplete() async {
    _workoutStopwatch.stop();
    _playCheer();
    HapticFeedback.heavyImpact();

    // Save workout log to Firestore
    try {
      final now = DateTime.now();
      final log = WorkoutLog(
        id: const Uuid().v4(),
        date: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        exerciseTypes: _completedExercises.map((e) => e['category'] as String).toSet().toList(),
        exercises: _completedExercises
            .map((e) => LoggedExercise(
                  id: const Uuid().v4(),
                  name: e['name'] as String,
                  sets: List.generate(
                    e['sets'] as int,
                    (i) => WorkoutSet(
                      id: const Uuid().v4(),
                      reps: e['reps'] as String,
                      weight: '',
                    ),
                  ),
                ))
            .toList(),
        createdAt: now.toIso8601String(),
      );
      await _firestoreService.addWorkoutLog(log);
    } catch (_) {
      // Silent fail — don't block the celebration
    }

    if (!mounted) return;

    final elapsed = _workoutStopwatch.elapsed;
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Workout Complete!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Great job! You crushed it! 💪',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: '${minutes}m ${seconds}s',
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  _StatColumn(
                    icon: Icons.fitness_center,
                    label: 'Exercises',
                    value: '${_completedExercises.length}',
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  _StatColumn(
                    icon: Icons.repeat,
                    label: 'Sets',
                    value: '${_completedExercises.fold<int>(0, (sum, e) => sum + (e['sets'] as int))}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Session saved to your history ✅',
              style: TextStyle(color: AppColors.success, fontSize: 12),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('FINISH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───
  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _overallProgress {
    final totalExercises = widget.plan.exercises.length;
    if (totalExercises == 0) return 0;
    return (_currentExerciseIndex + (_currentSet - 1) / widget.plan.exercises[_currentExerciseIndex].sets) / totalExercises;
  }

  String _getElapsedTime() {
    final elapsed = _workoutStopwatch.elapsed;
    return '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // ─── BUILD ───
  @override
  Widget build(BuildContext context) {
    if (widget.plan.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.plan.title)),
        body: const Center(
          child: Text('No exercises in this plan.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final exercise = widget.plan.exercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.plan.title,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          // Live elapsed time
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (_, __) => Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _getElapsedTime(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Main Exercise View ───
            Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: _overallProgress,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Exercise counter
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Exercise ${_currentExerciseIndex + 1} of ${widget.plan.exercises.length}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Exercise name
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Exercise visual placeholder
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getExerciseIcon(exercise.category),
                                    size: 72,
                                    color: AppColors.primary.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    exercise.weightRecommendation,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats row
                        Row(
                          children: [
                            _StatCard(
                              label: 'SET',
                              value: '$_currentSet / ${exercise.sets}',
                              icon: Icons.repeat,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              label: 'REPS',
                              value: exercise.reps,
                              icon: Icons.speed,
                              color: AppColors.accentOrange,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              label: 'REST',
                              value: '${exercise.restBetweenSetsSeconds}s',
                              icon: Icons.hourglass_bottom,
                              color: AppColors.accentPurple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tips
                        if (exercise.tipsOrGoal.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    exercise.tipsOrGoal,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Navigation row
                        Row(
                          children: [
                            // Previous
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: IconButton(
                                onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                                icon: const Icon(Icons.skip_previous_rounded, size: 28),
                                color: AppColors.textPrimary,
                                disabledColor: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Main action button
                            Expanded(
                              child: ScaleTransition(
                                scale: _pulseAnimation,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.background,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 4,
                                  ),
                                  onPressed: _finishSet,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _currentSet < exercise.sets ? Icons.check_circle : Icons.flag,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _currentSet < exercise.sets
                                            ? 'COMPLETE SET $_currentSet'
                                            : 'FINISH EXERCISE',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Next
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: IconButton(
                                onPressed: _nextExercise,
                                icon: const Icon(Icons.skip_next_rounded, size: 28),
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ─── Rest Timer Overlay ───
            if (_isResting)
              _RestTimerOverlay(
                timeRemaining: _timeRemaining,
                totalDuration: _totalRestDuration,
                formatTime: _formatTime,
                nextExerciseName: exercise.name,
                currentSet: _currentSet,
                totalSets: exercise.sets,
                onSkip: _skipRest,
                onAddTime: () => _addRestTime(20),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getExerciseIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('chest')) return Icons.accessibility_new;
    if (cat.contains('back')) return Icons.airline_seat_flat;
    if (cat.contains('leg') || cat.contains('quad') || cat.contains('hamstring')) return Icons.directions_walk;
    if (cat.contains('shoulder') || cat.contains('delt')) return Icons.accessibility;
    if (cat.contains('arm') || cat.contains('bicep') || cat.contains('tricep')) return Icons.fitness_center;
    if (cat.contains('core') || cat.contains('ab')) return Icons.self_improvement;
    if (cat.contains('cardio')) return Icons.directions_run;
    return Icons.fitness_center;
  }
}

// ─── Rest Timer Overlay Widget ───
class _RestTimerOverlay extends StatelessWidget {
  final int timeRemaining;
  final int totalDuration;
  final String Function(int) formatTime;
  final String nextExerciseName;
  final int currentSet;
  final int totalSets;
  final VoidCallback onSkip;
  final VoidCallback onAddTime;

  const _RestTimerOverlay({
    required this.timeRemaining,
    required this.totalDuration,
    required this.formatTime,
    required this.nextExerciseName,
    required this.currentSet,
    required this.totalSets,
    required this.onSkip,
    required this.onAddTime,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalDuration > 0 ? timeRemaining / totalDuration : 0.0;

    return Container(
      color: AppColors.background.withValues(alpha: 0.97),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'REST TIME',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 32),

            // Circular timer
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    color: AppColors.primary,
                    backgroundColor: AppColors.border,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(timeRemaining),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'remaining',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Up next info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text('UP NEXT', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Text(
                    nextExerciseName,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set $currentSet of $totalSets',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // +20s button
                OutlinedButton.icon(
                  onPressed: onAddTime,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('+20s', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(width: 16),
                // Skip button
                ElevatedButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.skip_next_rounded, size: 20),
                  label: const Text('SKIP REST', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card Widget ───
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Column (for completion dialog) ───
class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}
