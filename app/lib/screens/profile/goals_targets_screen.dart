import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class GoalsTargetsScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const GoalsTargetsScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<GoalsTargetsScreen> createState() => _GoalsTargetsScreenState();
}

class _GoalsTargetsScreenState extends State<GoalsTargetsScreen> {
  final _firestoreService = FirestoreService();
  late UserProfile _currentProfile;

  String _fitnessGoal = 'Muscle Building';
  double _caloriesGoal = 2400;
  double _proteinGoal = 125;
  double _carbsGoal = 300;
  double _fatGoal = 70;
  double _waterGoal = 3.0;
  double _fiberGoal = 30;
  double _targetWeight = 80.0;
  bool _isSaving = false;

  final List<String> _goalsList = [
    'Weight Loss',
    'Weight Gain',
    'Muscle Building',
    'Body Recomposition',
    'Maintain Weight',
    'General Fitness'
  ];

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _loadGoalsData();
  }

  void _loadGoalsData() {
    _fitnessGoal = _currentProfile.basicProfile['goal'] ?? 'Muscle Building';
    
    final goals = _currentProfile.goals;
    _caloriesGoal = (goals['caloriesGoal'] as num?)?.toDouble() ?? 2400.0;
    _proteinGoal = (goals['proteinGoal'] as num?)?.toDouble() ?? 125.0;
    _carbsGoal = (goals['carbsGoal'] as num?)?.toDouble() ?? 300.0;
    _fatGoal = (goals['fatGoal'] as num?)?.toDouble() ?? 70.0;
    _waterGoal = (goals['waterGoal'] as num?)?.toDouble() ?? 3.0;
    _fiberGoal = (goals['fiberGoal'] as num?)?.toDouble() ?? 30.0;
    _targetWeight = (goals['targetWeight'] as num?)?.toDouble() ?? 80.0;
  }

  Future<void> _saveGoals() async {
    setState(() => _isSaving = true);

    final updatedBasic = Map<String, dynamic>.from(_currentProfile.basicProfile);
    updatedBasic['goal'] = _fitnessGoal;

    final updatedGoals = Map<String, dynamic>.from(_currentProfile.goals);
    updatedGoals['caloriesGoal'] = _caloriesGoal;
    updatedGoals['proteinGoal'] = _proteinGoal;
    updatedGoals['carbsGoal'] = _carbsGoal;
    updatedGoals['fatGoal'] = _fatGoal;
    updatedGoals['waterGoal'] = _waterGoal;
    updatedGoals['fiberGoal'] = _fiberGoal;
    updatedGoals['targetWeight'] = _targetWeight;

    final updatedProfile = UserProfile(
      uid: _currentProfile.uid,
      email: _currentProfile.email,
      onboardingCompleted: _currentProfile.onboardingCompleted,
      basicProfile: updatedBasic,
      goals: updatedGoals,
      personalInfo: _currentProfile.personalInfo,
      advancedMetrics: _currentProfile.advancedMetrics,
      healthInfo: _currentProfile.healthInfo,
      gymInfo: _currentProfile.gymInfo,
      aiPreferences: _currentProfile.aiPreferences,
      connectedDevices: _currentProfile.connectedDevices,
      notifications: _currentProfile.notifications,
      progressPhotos: _currentProfile.progressPhotos,
    );

    try {
      await _firestoreService.saveUserProfile(updatedProfile);
      widget.onProfileUpdated(updatedProfile);
      setState(() {
        _currentProfile = updatedProfile;
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goals and daily targets updated! 🎯'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update goals: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goals & Targets', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              onPressed: _saveGoals,
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Primary Goal'),
            const SizedBox(height: 10),

            // Goal Details card
            AppCard(
              onTap: () => _editPrimaryGoal(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.track_changes_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_fitnessGoal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Target Weight: ${_targetWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 24),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Daily Targets'),
            const SizedBox(height: 10),

            // Daily targets list
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildTargetRow('Calories', '${_caloriesGoal.round()} kcal', Icons.local_fire_department_rounded, AppColors.accentOrange, () => _editTargetValue('Calories', _caloriesGoal, 'kcal', (v) => setState(() => _caloriesGoal = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildTargetRow('Protein', '${_proteinGoal.round()} g', Icons.fitness_center_rounded, AppColors.primaryBright, () => _editTargetValue('Protein', _proteinGoal, 'g', (v) => setState(() => _proteinGoal = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildTargetRow('Carbs', '${_carbsGoal.round()} g', Icons.flatware_rounded, AppColors.accent, () => _editTargetValue('Carbohydrates', _carbsGoal, 'g', (v) => setState(() => _carbsGoal = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildTargetRow('Fats', '${_fatGoal.round()} g', Icons.opacity_rounded, AppColors.accentPurple, () => _editTargetValue('Fats', _fatGoal, 'g', (v) => setState(() => _fatGoal = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildTargetRow('Water', '${_waterGoal.toStringAsFixed(1)} L', Icons.local_drink_rounded, Colors.blue, () => _editTargetValue('Water', _waterGoal, 'L', (v) => setState(() => _waterGoal = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildTargetRow('Fiber', '${_fiberGoal.round()} g', Icons.eco_rounded, Colors.greenAccent, () => _editTargetValue('Fiber', _fiberGoal, 'g', (v) => setState(() => _fiberGoal = v))),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: GradientButton(
                text: 'Save Targets & Recalculate',
                onPressed: _isSaving ? null : _saveGoals,
                isLoading: _isSaving,
                icon: Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetRow(String title, String val, IconData icon, Color iconColor, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(val, style: TextStyle(fontWeight: FontWeight.w800, color: iconColor, fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  void _editPrimaryGoal() {
    final weightController = TextEditingController(text: _targetWeight.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Primary Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _fitnessGoal,
                dropdownColor: AppColors.cardBg,
                decoration: const InputDecoration(labelText: 'Goal Type'),
                items: _goalsList.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _fitnessGoal = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Target Weight (kg)'),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Update Primary Goal',
                onPressed: () {
                  setState(() {
                    _targetWeight = double.tryParse(weightController.text) ?? _targetWeight;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editTargetValue(String label, double currentVal, String unit, ValueChanged<double> onSaved) {
    final controller = TextEditingController(text: currentVal.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Daily $label Target', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: '$label target value ($unit)',
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Save Target',
                onPressed: () {
                  final val = double.tryParse(controller.text);
                  if (val != null) {
                    onSaved(val);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
