import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';
import 'workout_player_screen.dart';
import 'workouts_screen.dart';

class SavedTemplatesScreen extends StatefulWidget {
  const SavedTemplatesScreen({super.key});

  @override
  State<SavedTemplatesScreen> createState() => _SavedTemplatesScreenState();
}

class _SavedTemplatesScreenState extends State<SavedTemplatesScreen> {
  final _firestoreService = FirestoreService();
  String _sortBy = 'recent'; // 'recent', 'name'
  List<Exercise> _allExercises = [];

  final List<WorkoutTemplate> _defaultTemplates = [
    WorkoutTemplate(
      id: 'default_push',
      name: 'Push Day',
      exerciseNames: ['Bench Press', 'Incline Dumbbell Press', 'Push Ups', 'Dips'],
      muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
    ),
    WorkoutTemplate(
      id: 'default_pull',
      name: 'Pull Day',
      exerciseNames: ['Lat Pulldown', 'Pull Ups', 'Biceps Curl'],
      muscleGroups: ['Back', 'Biceps'],
    ),
    WorkoutTemplate(
      id: 'default_legs',
      name: 'Leg Day',
      exerciseNames: ['Squats', 'Calf Raises'],
      muscleGroups: ['Legs'],
    ),
    WorkoutTemplate(
      id: 'default_upper',
      name: 'Upper Body',
      exerciseNames: ['Bench Press', 'Incline Dumbbell Press', 'Pull Ups', 'Dips'],
      muscleGroups: ['Chest', 'Back', 'Shoulders', 'Arms'],
    ),
    WorkoutTemplate(
      id: 'default_full',
      name: 'Full Body',
      exerciseNames: ['Squats', 'Bench Press', 'Pull Ups', 'Push Ups'],
      muscleGroups: ['Chest', 'Back', 'Legs', 'Shoulders'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _firestoreService.getExercises();
      setState(() {
        _allExercises = exercises;
      });
    } catch (_) {
      // Ignore errors
    }
  }

  void _showCreateTemplateDialog() {
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

  Exercise? _getExerciseByName(String name) {
    try {
      return _allExercises.firstWhere((e) => e.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  void _startWorkout(WorkoutTemplate template) {
    final plan = StructuredWorkoutPlan(
      title: template.name,
      exercises: template.exerciseNames.map((name) {
        final exObj = _getExerciseByName(name);
        return WorkoutExercise(
          category: exObj?.muscleGroup ?? (template.muscleGroups.isNotEmpty ? template.muscleGroups.first : 'General'),
          name: name,
          sets: 3,
          reps: '10',
          weightRecommendation: '0 kg',
          restBetweenSetsSeconds: 60,
          restAfterExerciseSeconds: 120,
          tipsOrGoal: '',
        );
      }).toList(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutPlayerScreen(plan: plan),
      ),
    );
  }

  void _showTemplateDetails(WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Target Muscles: ${template.muscleGroups.join(", ")}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                'Exercises list:',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: template.exerciseNames.length,
                  itemBuilder: (_, i) {
                    final name = template.exerciseNames[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center, color: AppColors.primary, size: 16),
                          const SizedBox(width: 12),
                          Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Start Workout Session',
                onPressed: () {
                  Navigator.pop(ctx);
                  _startWorkout(template);
                },
                icon: Icons.play_arrow_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTemplate(WorkoutTemplate template) async {
    final confirm = await showDialog<bool>(
      context: context,
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
      if (template.id.startsWith('default_')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete default templates'), backgroundColor: AppColors.error),
        );
      } else {
        await _firestoreService.deleteWorkoutTemplate(template.id);
        setState(() {}); // refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Workout Plans'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
            onPressed: _showCreateTemplateDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<WorkoutTemplate>>(
        stream: _firestoreService.getWorkoutTemplatesStream(),
        builder: (context, snapshot) {
          final dbTemplates = snapshot.data ?? [];
          final allTemplates = [...dbTemplates, ..._defaultTemplates];

          // Sort
          if (_sortBy == 'name') {
            allTemplates.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          }

          final quickStartTemplates = allTemplates.take(4).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Start Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Quick Start ⚡',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Your go-to workouts, ready to start',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: quickStartTemplates.length,
                    itemBuilder: (context, index) {
                      final template = quickStartTemplates[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => _showTemplateDetails(template),
                          child: Container(
                            width: 145,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Anatomy painter
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.background.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: CustomPaint(
                                        size: const Size(60, 90),
                                        painter: BodyAnatomyPainter(targetedMuscles: template.muscleGroups),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  template.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  template.muscleGroups.join(', '),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${template.exerciseNames.length} exercises',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // All Templates Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Templates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _sortBy = _sortBy == 'recent' ? 'name' : 'recent';
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              _sortBy == 'recent' ? 'Sort: Recent ' : 'Sort: Name ',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Vertical List of All Templates
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allTemplates.length,
                  itemBuilder: (context, index) {
                    final template = allTemplates[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () => _showTemplateDetails(template),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Mini Anatomy illustration
                            Container(
                              width: 55,
                              height: 55,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.background.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CustomPaint(
                                size: const Size(40, 50),
                                painter: BodyAnatomyPainter(targetedMuscles: template.muscleGroups),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    template.muscleGroups.join(', '),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${template.exerciseNames.length} exercises',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // More Menu
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                              color: AppColors.cardBg,
                              onSelected: (value) {
                                if (value == 'start') {
                                  _startWorkout(template);
                                } else if (value == 'delete') {
                                  _deleteTemplate(template);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'start',
                                  child: Row(
                                    children: [
                                      Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 18),
                                      SizedBox(width: 8),
                                      Text('Start Session'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete Plan', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }
}

// ─── BODY ANATOMY PAINTER ───
class BodyAnatomyPainter extends CustomPainter {
  final List<String> targetedMuscles;

  BodyAnatomyPainter({required this.targetedMuscles});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBase = Paint()
      ..color = AppColors.textMuted.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final paintActive = Paint()
      ..color = AppColors.accentPurple
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double cx = size.width / 2;
    final double h = size.height;

    // Body dimensions proportional to size
    final double headRadius = h * 0.08;
    final double headY = h * 0.12;

    final double neckWidth = cx * 0.15;
    final double neckHeight = h * 0.04;
    final double neckY = headY + headRadius;

    final double shoulderWidth = cx * 0.8;
    final double shoulderHeight = h * 0.06;
    final double chestY = neckY + neckHeight;

    final double waistWidth = cx * 0.45;
    final double absY = chestY + shoulderHeight;
    final double absHeight = h * 0.18;

    final double armWidth = cx * 0.22;
    final double armHeight = h * 0.35;

    final double legWidth = cx * 0.28;
    final double legHeight = h * 0.45;
    final double hipsY = absY + absHeight;

    // 1. Head
    bool hasHeadActive = targetedMuscles.contains('Cardio') || targetedMuscles.contains('Full Body');
    canvas.drawCircle(Offset(cx, headY), headRadius, hasHeadActive ? paintActive : paintBase);
    canvas.drawCircle(Offset(cx, headY), headRadius, paintStroke);

    // 2. Neck
    canvas.drawRect(Rect.fromLTWH(cx - neckWidth / 2, neckY, neckWidth, neckHeight), paintBase);
    canvas.drawRect(Rect.fromLTWH(cx - neckWidth / 2, neckY, neckWidth, neckHeight), paintStroke);

    // 3. Chest & Shoulders
    bool hasChestActive = targetedMuscles.any((m) => m == 'Chest' || m == 'Back' || m == 'Full Body' || m == 'Cardio');
    bool hasShouldersActive = targetedMuscles.any((m) => m == 'Shoulders' || m == 'Full Body' || m == 'Cardio');

    final chestPath = Path()
      ..moveTo(cx - shoulderWidth, chestY)
      ..lineTo(cx + shoulderWidth, chestY)
      ..lineTo(cx + waistWidth, absY)
      ..lineTo(cx - waistWidth, absY)
      ..close();
    canvas.drawPath(chestPath, (hasChestActive || hasShouldersActive) ? paintActive : paintBase);
    canvas.drawPath(chestPath, paintStroke);

    // 4. Abs / Midsection
    bool hasAbsActive = targetedMuscles.any((m) => m == 'Abs' || m == 'Full Body' || m == 'Cardio');
    final absPath = Path()
      ..moveTo(cx - waistWidth, absY)
      ..lineTo(cx + waistWidth, absY)
      ..lineTo(cx + waistWidth * 0.8, hipsY)
      ..lineTo(cx - waistWidth * 0.8, hipsY)
      ..close();
    canvas.drawPath(absPath, hasAbsActive ? paintActive : paintBase);
    canvas.drawPath(absPath, paintStroke);

    // 5. Arms (Left & Right)
    bool hasArmsActive = targetedMuscles.any((m) => m == 'Arms' || m == 'Biceps' || m == 'Triceps' || m == 'Full Body');
    // Left Arm
    final leftArmPath = Path()
      ..moveTo(cx - shoulderWidth, chestY)
      ..lineTo(cx - shoulderWidth - armWidth, chestY + armHeight)
      ..lineTo(cx - shoulderWidth - armWidth + 4, chestY + armHeight + 2)
      ..lineTo(cx - waistWidth, absY)
      ..close();
    canvas.drawPath(leftArmPath, hasArmsActive ? paintActive : paintBase);
    canvas.drawPath(leftArmPath, paintStroke);

    // Right Arm
    final rightArmPath = Path()
      ..moveTo(cx + shoulderWidth, chestY)
      ..lineTo(cx + shoulderWidth + armWidth, chestY + armHeight)
      ..lineTo(cx + shoulderWidth + armWidth - 4, chestY + armHeight + 2)
      ..lineTo(cx + waistWidth, absY)
      ..close();
    canvas.drawPath(rightArmPath, hasArmsActive ? paintActive : paintBase);
    canvas.drawPath(rightArmPath, paintStroke);

    // 6. Legs (Left & Right)
    bool hasLegsActive = targetedMuscles.any((m) => m == 'Legs' || m == 'Full Body' || m == 'Cardio');
    // Left Leg
    final leftLegPath = Path()
      ..moveTo(cx - waistWidth * 0.8, hipsY)
      ..lineTo(cx - legWidth / 2, hipsY + legHeight)
      ..lineTo(cx - legWidth * 1.3, hipsY + legHeight)
      ..lineTo(cx - waistWidth * 0.1, hipsY)
      ..close();
    canvas.drawPath(leftLegPath, hasLegsActive ? paintActive : paintBase);
    canvas.drawPath(leftLegPath, paintStroke);

    // Right Leg
    final rightLegPath = Path()
      ..moveTo(cx + waistWidth * 0.8, hipsY)
      ..lineTo(cx + legWidth / 2, hipsY + legHeight)
      ..lineTo(cx + legWidth * 1.3, hipsY + legHeight)
      ..lineTo(cx + waistWidth * 0.1, hipsY)
      ..close();
    canvas.drawPath(rightLegPath, hasLegsActive ? paintActive : paintBase);
    canvas.drawPath(rightLegPath, paintStroke);
  }

  @override
  bool shouldRepaint(covariant BodyAnatomyPainter oldDelegate) {
    return oldDelegate.targetedMuscles != targetedMuscles;
  }
}
