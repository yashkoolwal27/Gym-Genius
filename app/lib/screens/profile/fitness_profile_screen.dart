import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class FitnessProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const FitnessProfileScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<FitnessProfileScreen> createState() => _FitnessProfileScreenState();
}

class _FitnessProfileScreenState extends State<FitnessProfileScreen> {
  final _firestoreService = FirestoreService();
  late UserProfile _currentProfile;

  String _fitnessLevel = 'Beginner';
  String _primaryTrainingStyle = 'General Fitness';
  String _secondaryTrainingStyle = 'None';
  List<String> _selectedEquipment = [];
  bool _isSaving = false;

  final List<String> _fitnessLevels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _trainingStyles = [
    'Bodybuilding',
    'Powerlifting',
    'Weightlifting',
    'Calisthenics',
    'CrossFit',
    'Fat Loss',
    'Athletic Performance',
    'General Fitness'
  ];
  final List<String> _secondaryStyles = [
    'None',
    'Bodybuilding',
    'Powerlifting',
    'Weightlifting',
    'Calisthenics',
    'CrossFit',
    'Fat Loss',
    'Athletic Performance',
    'General Fitness'
  ];
  final List<String> _equipmentOptions = [
    'Barbell',
    'Dumbbell',
    'Machine',
    'Bodyweight',
    'Cable',
    'Smith Machine',
    'Kettlebell',
    'Band'
  ];

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _loadFitnessProfile();
  }

  void _loadFitnessProfile() {
    _fitnessLevel = _currentProfile.fitnessLevel;
    _primaryTrainingStyle = _currentProfile.primaryTrainingStyle;
    _secondaryTrainingStyle = _currentProfile.secondaryTrainingStyle;
    _selectedEquipment = List<String>.from(_currentProfile.availableEquipment);
  }

  Future<void> _saveFitnessProfile() async {
    setState(() => _isSaving = true);

    final updatedBasic = Map<String, dynamic>.from(_currentProfile.basicProfile);
    updatedBasic['fitnessLevel'] = _fitnessLevel;
    updatedBasic['primaryTrainingStyle'] = _primaryTrainingStyle;
    updatedBasic['secondaryTrainingStyle'] = _secondaryTrainingStyle;
    updatedBasic['availableEquipment'] = _selectedEquipment;

    final updatedProfile = UserProfile(
      uid: _currentProfile.uid,
      email: _currentProfile.email,
      onboardingCompleted: _currentProfile.onboardingCompleted,
      basicProfile: updatedBasic,
      goals: _currentProfile.goals,
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
          const SnackBar(
            content: Text('Fitness profile updated successfully! 💪'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update fitness profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout & Fitness Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              onPressed: _saveFitnessProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fitness Level Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Experience Level',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: _fitnessLevels.map((lvl) {
                      final isSel = _fitnessLevel == lvl;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() => _fitnessLevel = lvl),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel ? AppColors.primary : AppColors.border,
                                  width: 1.5,
                                ),
                                color: isSel ? AppColors.primary.withOpacity(0.05) : AppColors.cardBg2,
                              ),
                              child: Center(
                                child: Text(
                                  lvl,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    color: isSel ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Primary Training Style Card
            _buildInteractiveCard(
              title: 'Primary Training Style',
              subtitle: _primaryTrainingStyle,
              icon: Icons.electric_bolt_rounded,
              color: Colors.amber,
              onTap: () => _showPickerBottomSheet('Primary Style', _trainingStyles, _primaryTrainingStyle, (val) {
                setState(() => _primaryTrainingStyle = val);
              }),
            ),
            const SizedBox(height: 16),

            // Secondary Training Style Card
            _buildInteractiveCard(
              title: 'Secondary Training Style',
              subtitle: _secondaryTrainingStyle,
              icon: Icons.flash_on_rounded,
              color: Colors.purpleAccent,
              onTap: () => _showPickerBottomSheet('Secondary Style', _secondaryStyles, _secondaryTrainingStyle, (val) {
                setState(() => _secondaryTrainingStyle = val);
              }),
            ),
            const SizedBox(height: 16),

            // Available Equipment Selection
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.handyman_rounded, color: Colors.blueAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Available Equipment',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _equipmentOptions.length,
                    itemBuilder: (context, index) {
                      final eq = _equipmentOptions[index];
                      final isSelected = _selectedEquipment.contains(eq);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedEquipment.remove(eq);
                            } else {
                              _selectedEquipment.add(eq);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 1.5,
                            ),
                            color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.cardBg2,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: isSelected ? AppColors.primary : AppColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  eq,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: GradientButton(
                text: 'Save Fitness Profile',
                onPressed: _isSaving ? null : _saveFitnessProfile,
                isLoading: _isSaving,
                icon: Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 22),
        ],
      ),
    );
  }

  void _showPickerBottomSheet(String sheetTitle, List<String> options, String currentVal, ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select $sheetTitle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, idx) {
                    final opt = options[idx];
                    return ListTile(
                      title: Text(opt, style: const TextStyle(color: AppColors.textPrimary)),
                      trailing: opt == currentVal ? const Icon(Icons.check, color: AppColors.primary) : null,
                      onTap: () {
                        onSelected(opt);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
