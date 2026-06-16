import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const BodyMeasurementsScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  final _firestoreService = FirestoreService();
  late UserProfile _currentProfile;

  double _weight = 70.0;
  double _chest = 0.0;
  double _waist = 0.0;
  double _shoulders = 0.0;
  double _biceps = 0.0;
  double _forearms = 0.0;
  double _thighs = 0.0;
  double _calves = 0.0;
  double _bodyFat = 15.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _loadMetrics();
  }

  void _loadMetrics() {
    _weight = _currentProfile.weight;
    
    final metrics = _currentProfile.advancedMetrics;
    _chest = (metrics['chest'] as num?)?.toDouble() ?? 102.0;
    _waist = (metrics['waist'] as num?)?.toDouble() ?? 78.0;
    _shoulders = (metrics['shoulders'] as num?)?.toDouble() ?? 48.0;
    _biceps = (metrics['biceps'] as num?)?.toDouble() ?? 36.0;
    _forearms = (metrics['forearms'] as num?)?.toDouble() ?? 30.0;
    _thighs = (metrics['thighs'] as num?)?.toDouble() ?? 59.0;
    _calves = (metrics['calves'] as num?)?.toDouble() ?? 38.0;
    _bodyFat = (metrics['bodyFat'] as num?)?.toDouble() ?? 15.2;
  }

  Future<void> _saveMetrics() async {
    setState(() => _isSaving = true);

    // Save back to weight in basicProfile, and advancedMetrics
    final updatedBasic = Map<String, dynamic>.from(_currentProfile.basicProfile);
    updatedBasic['weight'] = _weight;

    final updatedMetrics = Map<String, dynamic>.from(_currentProfile.advancedMetrics);
    updatedMetrics['chest'] = _chest;
    updatedMetrics['waist'] = _waist;
    updatedMetrics['shoulders'] = _shoulders;
    updatedMetrics['biceps'] = _biceps;
    updatedMetrics['forearms'] = _forearms;
    updatedMetrics['thighs'] = _thighs;
    updatedMetrics['calves'] = _calves;
    updatedMetrics['bodyFat'] = _bodyFat;

    final updatedProfile = UserProfile(
      uid: _currentProfile.uid,
      email: _currentProfile.email,
      onboardingCompleted: _currentProfile.onboardingCompleted,
      basicProfile: updatedBasic,
      goals: _currentProfile.goals,
      personalInfo: _currentProfile.personalInfo,
      advancedMetrics: updatedMetrics,
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
          const SnackBar(content: Text('Measurements updated successfully! 📐'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update measurements: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _addNewMeasurement() {
    String selectedMetric = 'Weight';
    final List<String> metricsList = [
      'Weight',
      'Chest',
      'Waist',
      'Shoulders',
      'Biceps',
      'Forearms',
      'Thighs',
      'Calves',
      'Body Fat %',
    ];

    double currentVal = _weight;
    final controller = TextEditingController(text: currentVal.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  const Text('Add New Measurement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMetric,
                    dropdownColor: AppColors.cardBg,
                    decoration: const InputDecoration(labelText: 'Select Metric'),
                    items: metricsList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() {
                          selectedMetric = v;
                          if (v == 'Weight') currentVal = _weight;
                          if (v == 'Chest') currentVal = _chest;
                          if (v == 'Waist') currentVal = _waist;
                          if (v == 'Shoulders') currentVal = _shoulders;
                          if (v == 'Biceps') currentVal = _biceps;
                          if (v == 'Forearms') currentVal = _forearms;
                          if (v == 'Thighs') currentVal = _thighs;
                          if (v == 'Calves') currentVal = _calves;
                          if (v == 'Body Fat %') currentVal = _bodyFat;
                          controller.text = currentVal.toString();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Value (${selectedMetric == 'Body Fat %' ? '%' : selectedMetric == 'Weight' ? 'kg' : 'cm'})',
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    text: 'Save Log',
                    onPressed: () {
                      final val = double.tryParse(controller.text);
                      if (val != null) {
                        setState(() {
                          if (selectedMetric == 'Weight') _weight = val;
                          if (selectedMetric == 'Chest') _chest = val;
                          if (selectedMetric == 'Waist') _waist = val;
                          if (selectedMetric == 'Shoulders') _shoulders = val;
                          if (selectedMetric == 'Biceps') _biceps = val;
                          if (selectedMetric == 'Forearms') _forearms = val;
                          if (selectedMetric == 'Thighs') _thighs = val;
                          if (selectedMetric == 'Calves') _calves = val;
                          if (selectedMetric == 'Body Fat %') _bodyFat = val;
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Body Measurements', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              onPressed: _saveMetrics,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Glowing neon green human body image
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 440,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/images/body_silhouette.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.cardBg2,
                          alignment: Alignment.center,
                          child: const Icon(Icons.accessibility_new_rounded, color: AppColors.primary, size: 60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right Side: Scrollable list of measurements
                  Expanded(
                    flex: 6,
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMeasurementRow('Weight', '${_weight.toStringAsFixed(1)} kg'),
                          const Divider(height: 1, color: AppColors.border),
                          _buildMeasurementRow('Chest', '${_chest.round()} cm'),
                          const Divider(height: 1, color: AppColors.border),
                          _buildMeasurementRow('Waist', '${_waist.round()} cm'),
                          const Divider(height: 1, color: AppColors.border),
                          _buildMeasurementRow('Shoulders', '${_shoulders.round()} cm'),
                          const Divider(height: 1, color: AppColors.border),
                          _buildMeasurementRow('Biceps', '${_biceps.round()} cm'),
                          const Divider(height: 1, color: AppColors.border),
                          _buildMeasurementRow('Forearms', '${_forearms.round()} cm'),
                          const Divider(height: 1, color: AppColors.border),
                          _buildMeasurementRow('Thighs', '${_thighs.round()} cm'),
                          const Divider(height: 1, color: AppColors.border),
                          _buildMeasurementRow('Calves', '${_calves.round()} cm'),
                          const Divider(height: 1, color: AppColors.border),
                          _buildMeasurementRow('Body Fat', '${_bodyFat.toStringAsFixed(1)} %'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom "+ Add New Measurement" button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _addNewMeasurement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add New Measurement',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }
}
