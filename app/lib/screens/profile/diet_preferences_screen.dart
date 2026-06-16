import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class DietPreferencesScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const DietPreferencesScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<DietPreferencesScreen> createState() => _DietPreferencesScreenState();
}

class _DietPreferencesScreenState extends State<DietPreferencesScreen> {
  final _firestoreService = FirestoreService();
  late UserProfile _currentProfile;

  String _dietType = 'Vegetarian';
  final _allergiesController = TextEditingController();
  final _dislikedController = TextEditingController();
  String _mealFrequency = '4 Meals a Day';
  String _dailyBudget = '₹ 250 - ₹ 400';
  final _cuisinesController = TextEditingController();
  bool _isSaving = false;

  final List<String> _diets = [
    'Vegetarian',
    'Eggitarian',
    'Non-Vegetarian',
    'Vegan',
    'Jain',
    'Custom'
  ];

  final List<String> _frequencies = [
    '2 Meals a Day',
    '3 Meals a Day',
    '4 Meals a Day',
    '5 Meals a Day',
    '6+ Meals a Day'
  ];

  final List<String> _budgets = [
    'Under ₹ 250',
    '₹ 250 - ₹ 400',
    '₹ 400 - ₹ 750',
    '₹ 750 - ₹ 1200',
    'Above ₹ 1200'
  ];

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _loadDietPreferences();
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _dislikedController.dispose();
    _cuisinesController.dispose();
    super.dispose();
  }

  void _loadDietPreferences() {
    _dietType = _currentProfile.basicProfile['dietPreference'] ?? 'Vegetarian';
    _allergiesController.text = _currentProfile.healthInfo['allergies'] ?? 'None';
    
    // Read from healthInfo or custom maps
    final health = _currentProfile.healthInfo;
    _dislikedController.text = health['dislikedFoods'] ?? 'None';
    _cuisinesController.text = health['preferredCuisines'] ?? 'Indian, Continental';
    _mealFrequency = health['mealFrequency'] ?? '4 Meals a Day';
    _dailyBudget = health['dailyBudget'] ?? '₹ 250 - ₹ 400';
  }

  Future<void> _saveDietPreferences() async {
    setState(() => _isSaving = true);

    // Merge diet info into basicProfile and healthInfo maps
    final updatedBasic = Map<String, dynamic>.from(_currentProfile.basicProfile);
    updatedBasic['dietPreference'] = _dietType;

    final updatedHealth = Map<String, dynamic>.from(_currentProfile.healthInfo);
    updatedHealth['allergies'] = _allergiesController.text.trim();
    updatedHealth['dislikedFoods'] = _dislikedController.text.trim();
    updatedHealth['preferredCuisines'] = _cuisinesController.text.trim();
    updatedHealth['mealFrequency'] = _mealFrequency;
    updatedHealth['dailyBudget'] = _dailyBudget;

    final updatedProfile = UserProfile(
      uid: _currentProfile.uid,
      email: _currentProfile.email,
      onboardingCompleted: _currentProfile.onboardingCompleted,
      basicProfile: updatedBasic,
      goals: _currentProfile.goals,
      personalInfo: _currentProfile.personalInfo,
      advancedMetrics: _currentProfile.advancedMetrics,
      healthInfo: updatedHealth,
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
          const SnackBar(content: Text('Diet preferences updated successfully! 🥗'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update diet settings: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Diet Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: _saveDietPreferences,
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Diet Type Selector
            _buildInteractiveCard(
              title: 'Diet Type',
              subtitle: _dietType,
              icon: Icons.eco_rounded,
              color: Colors.green,
              onTap: () => _showPickerBottomSheet('Diet Type', _diets, _dietType, (val) {
                setState(() => _dietType = val);
              }),
            ),
            const SizedBox(height: 12),

            // Allergies log
            _buildInputCard(
              title: 'Allergies / Intolerances',
              controller: _allergiesController,
              icon: Icons.warning_amber_rounded,
              color: Colors.redAccent,
              hint: 'e.g. Peanuts, Lactose, Gluten',
            ),
            const SizedBox(height: 12),

            // Disliked Foods
            _buildInputCard(
              title: 'Disliked Foods',
              controller: _dislikedController,
              icon: Icons.cancel_outlined,
              color: Colors.orangeAccent,
              hint: 'e.g. Bitter Gourd, Tofu, Eggplant',
            ),
            const SizedBox(height: 12),

            // Preferred Meal Frequency
            _buildInteractiveCard(
              title: 'Preferred Meal Frequency',
              subtitle: _mealFrequency,
              icon: Icons.av_timer_rounded,
              color: Colors.blueAccent,
              onTap: () => _showPickerBottomSheet('Meal Frequency', _frequencies, _mealFrequency, (val) {
                setState(() => _mealFrequency = val);
              }),
            ),
            const SizedBox(height: 12),

            // Daily Budget
            _buildInteractiveCard(
              title: 'Daily Budget for Food',
              subtitle: _dailyBudget,
              icon: Icons.payments_outlined,
              color: Colors.amber,
              onTap: () => _showPickerBottomSheet('Daily Budget', _budgets, _dailyBudget, (val) {
                setState(() => _dailyBudget = val);
              }),
            ),
            const SizedBox(height: 12),

            // Preferred Cuisines
            _buildInputCard(
              title: 'Preferred Cuisines',
              controller: _cuisinesController,
              icon: Icons.restaurant_rounded,
              color: Colors.pinkAccent,
              hint: 'e.g. Indian, Italian, Continental',
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: GradientButton(
                text: 'Save Preferences',
                onPressed: _isSaving ? null : _saveDietPreferences,
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
              color: color.withValues(alpha: 0.15),
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

  Widget _buildInputCard({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required String hint,
  }) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
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
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
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
