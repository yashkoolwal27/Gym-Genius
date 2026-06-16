import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/firestore_service.dart';
import '../../models/models.dart';
import '../main_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingScreen extends StatefulWidget {
  final String name;
  final String email;
  const OnboardingScreen({super.key, required this.name, required this.email});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _firestoreService = FirestoreService();

  // Onboarding controllers/values
  late final TextEditingController _nameController;
  final _ageController = TextEditingController(text: '25');
  
  // Height values
  final _heightController = TextEditingController(text: '170');
  final _ftController = TextEditingController(text: '5');
  final _inController = TextEditingController(text: '7');
  String _heightUnit = 'cm'; // cm or ft/in

  // Weight values
  final _weightController = TextEditingController(text: '70');
  String _weightUnit = 'kg'; // kg or lbs

  String _gender = 'Male';
  String _fitnessGoal = 'Muscle Building';
  String _activityLevel = 'Moderately Active';
  String _dietPreference = 'Vegetarian';

  // Calculated targets
  double _bmr = 0;
  double _tdee = 0;
  double _caloriesGoal = 0;
  double _proteinGoal = 0;
  double _carbsGoal = 0;
  double _fatGoal = 0;
  double _waterGoal = 0;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer Not To Say'];
  final List<String> _goals = [
    'Weight Loss',
    'Weight Gain',
    'Muscle Building',
    'Body Recomposition',
    'Maintain Weight',
    'General Fitness'
  ];
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Athlete'
  ];
  final List<String> _diets = [
    'Vegetarian',
    'Eggitarian',
    'Non-Vegetarian',
    'Vegan',
    'Jain',
    'Custom'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _ftController.dispose();
    _inController.dispose();
    _weightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Helper: converts input height to cm
  double _getCalculatedHeightCm() {
    if (_heightUnit == 'cm') {
      return double.tryParse(_heightController.text) ?? 170.0;
    } else {
      final ft = double.tryParse(_ftController.text) ?? 5.0;
      final inch = double.tryParse(_inController.text) ?? 7.0;
      return (ft * 12 + inch) * 2.54;
    }
  }

  // Helper: converts input weight to kg
  double _getCalculatedWeightKg() {
    final raw = double.tryParse(_weightController.text) ?? 70.0;
    if (_weightUnit == 'kg') {
      return raw;
    } else {
      return raw * 0.45359237;
    }
  }

  void _calculateStartingPlan() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final heightCm = _getCalculatedHeightCm();
    final weightKg = _getCalculatedWeightKg();

    // 1. Calculate BMR (Mifflin-St Jeor)
    if (_gender == 'Male') {
      _bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else if (_gender == 'Female') {
      _bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    } else {
      _bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 78; // average
    }

    // 2. Calculate TDEE
    double multiplier = 1.2;
    switch (_activityLevel) {
      case 'Sedentary':
        multiplier = 1.2;
        break;
      case 'Lightly Active':
        multiplier = 1.375;
        break;
      case 'Moderately Active':
        multiplier = 1.55;
        break;
      case 'Very Active':
        multiplier = 1.725;
        break;
      case 'Athlete':
        multiplier = 1.9;
        break;
    }
    _tdee = _bmr * multiplier;

    // 3. Calories Goal
    _caloriesGoal = _tdee;
    switch (_fitnessGoal) {
      case 'Weight Loss':
        _caloriesGoal -= 500;
        break;
      case 'Weight Gain':
        _caloriesGoal += 500;
        break;
      case 'Muscle Building':
        _caloriesGoal += 300;
        break;
      case 'Body Recomposition':
        _caloriesGoal -= 100;
        break;
    }
    if (_caloriesGoal < 1200) _caloriesGoal = 1200;

    // 4. Macros Goal
    // Protein: Muscle Gain/Building/Recomp needs more protein
    if (_fitnessGoal == 'Muscle Building' || _fitnessGoal == 'Weight Gain' || _fitnessGoal == 'Body Recomposition') {
      _proteinGoal = weightKg * 2.2;
    } else {
      _proteinGoal = weightKg * 1.6;
    }

    // Fat: 25% of calories
    _fatGoal = (_caloriesGoal * 0.25) / 9.0;

    // Carbs: remaining calories
    _carbsGoal = (_caloriesGoal - (_proteinGoal * 4) - (_fatGoal * 9)) / 4.0;
    if (_carbsGoal < 50) _carbsGoal = 50; // safeguard

    // Water: 35ml per kg of body weight
    _waterGoal = (weightKg * 35) / 1000.0;
  }

  Future<void> _completeOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final age = int.tryParse(_ageController.text) ?? 25;
    final heightCm = _getCalculatedHeightCm();
    final weightKg = _getCalculatedWeightKg();

    final profile = UserProfile(
      uid: user.uid,
      email: widget.email,
      onboardingCompleted: true,
      basicProfile: {
        'name': _nameController.text.trim(),
        'gender': _gender,
        'age': age,
        'height': double.parse(heightCm.toStringAsFixed(1)),
        'weight': double.parse(weightKg.toStringAsFixed(1)),
        'goal': _fitnessGoal,
        'activityLevel': _activityLevel,
        'dietPreference': _dietPreference,
      },
      goals: {
        'caloriesGoal': double.parse(_caloriesGoal.toStringAsFixed(0)),
        'proteinGoal': double.parse(_proteinGoal.toStringAsFixed(0)),
        'carbsGoal': double.parse(_carbsGoal.toStringAsFixed(0)),
        'fatGoal': double.parse(_fatGoal.toStringAsFixed(0)),
        'waterGoal': double.parse(_waterGoal.toStringAsFixed(1)),
      },
    );

    try {
      await _firestoreService.saveUserProfile(profile);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _nextPage() {
    // Basic Input Validations
    if (_currentPage == 1 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_currentPage == 2) {
      final age = int.tryParse(_ageController.text);
      if (age == null || age < 10 || age > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid age (10-100)'), backgroundColor: AppColors.error),
        );
        return;
      }
      final weight = double.tryParse(_weightController.text);
      if (weight == null || weight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid weight'), backgroundColor: AppColors.error),
        );
        return;
      }
      if (_heightUnit == 'cm') {
        final height = double.tryParse(_heightController.text);
        if (height == null || height < 100 || height > 250) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid height in cm (100-250)'), backgroundColor: AppColors.error),
          );
          return;
        }
      } else {
        final ft = int.tryParse(_ftController.text);
        final inch = int.tryParse(_inController.text);
        if (ft == null || ft <= 0 || inch == null || inch < 0 || inch >= 12) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid feet (e.g. 5) and inches (0-11)'), backgroundColor: AppColors.error),
          );
          return;
        }
      }
    }

    if (_currentPage == 5) {
      // Transitioning to Step 7 (AI calculation target screen)
      _calculateStartingPlan();
    }

    if (_currentPage < 6) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar at the top (if not welcome page)
              if (_currentPage > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step $_currentPage of 6',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          Text(
                            '${((_currentPage / 6) * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _currentPage / 6,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    _buildWelcomeScreen(),
                    _buildBasicInformation(),
                    _buildBodyInformation(),
                    _buildFitnessGoal(),
                    _buildActivityLevel(),
                    _buildDietPreference(),
                    _buildAICalculation(),
                  ],
                ),
              ),

              // Footer navigation
              if (_currentPage > 0)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 1)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          },
                          child: const Text('Back', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        )
                      else
                        const SizedBox(),
                      
                      SizedBox(
                        width: 160,
                        child: GradientButton(
                          text: _currentPage == 6 ? 'Start My Journey' : 'Continue',
                          onPressed: _nextPage,
                          icon: _currentPage == 6 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Welcome Screen
  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Gym-Genius',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1),
          ),
          const SizedBox(height: 12),
          const Text(
            "Let's build your personalized fitness plan in under 60 seconds.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 220,
            child: GradientButton(
              text: 'Continue',
              onPressed: _nextPage,
              icon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Basic Information
  Widget _buildBasicInformation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'We use this to build customized targets.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What is your name?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Enter Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What is your gender?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                Column(
                  children: _genders.map((g) {
                    final isSel = _gender == g;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => setState(() => _gender = g),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: 1.5),
                            color: isSel ? AppColors.primary.withOpacity(0.05) : AppColors.cardBg2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(g, style: TextStyle(color: isSel ? AppColors.primary : AppColors.textPrimary, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                              if (isSel) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Body Information
  Widget _buildBodyInformation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Body Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Required for calorie and macro calculations.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Age
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Age', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Enter Age (e.g. 25)',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Height with Unit Toggle
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Height', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Row(
                      children: [
                        _buildUnitToggle(
                          label: 'cm',
                          isSel: _heightUnit == 'cm',
                          onTap: () => setState(() => _heightUnit = 'cm'),
                        ),
                        const SizedBox(width: 4),
                        _buildUnitToggle(
                          label: 'ft/in',
                          isSel: _heightUnit == 'ft/in',
                          onTap: () => setState(() => _heightUnit = 'ft/in'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_heightUnit == 'cm')
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Height in cm (e.g. 175)',
                      prefixIcon: Icon(Icons.height_rounded),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ftController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Feet (ft)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _inController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Inches (in)',
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Weight with Unit Toggle
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weight', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Row(
                      children: [
                        _buildUnitToggle(
                          label: 'kg',
                          isSel: _weightUnit == 'kg',
                          onTap: () => setState(() => _weightUnit = 'kg'),
                        ),
                        const SizedBox(width: 4),
                        _buildUnitToggle(
                          label: 'lbs',
                          isSel: _weightUnit == 'lbs',
                          onTap: () => setState(() => _weightUnit = 'lbs'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Weight in $_weightUnit',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle({required String label, required bool isSel, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSel ? AppColors.primary : AppColors.cardBg2,
          border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // 4. Fitness Goal
  Widget _buildFitnessGoal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your fitness goal?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us adjust your nutritional calculation.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSel = _fitnessGoal == goal;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => setState(() => _fitnessGoal = goal),
                    child: Row(
                      children: [
                        Icon(
                          isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: isSel ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          goal,
                          style: TextStyle(
                            color: isSel ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 5. Activity Level
  Widget _buildActivityLevel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your activity level',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Helps in estimating your total daily energy output.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _activityLevels.length,
              itemBuilder: (context, index) {
                final level = _activityLevels[index];
                final isSel = _activityLevel == level;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => setState(() => _activityLevel = level),
                    child: Row(
                      children: [
                        Icon(
                          isSel ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: isSel ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          level,
                          style: TextStyle(
                            color: isSel ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 6. Diet Preference
  Widget _buildDietPreference() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your diet preference',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'We customize recommendations to match your diet.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _diets.length,
              itemBuilder: (context, index) {
                final diet = _diets[index];
                final isSel = _dietPreference == diet;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => setState(() => _dietPreference = diet),
                    child: Row(
                      children: [
                        Icon(
                          isSel ? Icons.restaurant_rounded : Icons.restaurant_menu_rounded,
                          color: isSel ? AppColors.primary : AppColors.textMuted,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          diet,
                          style: TextStyle(
                            color: isSel ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 7. AI Goal Calculation
  Widget _buildAICalculation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(Icons.auto_awesome_rounded, size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Your Starting Plan',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Based on your: Weight, Goal, Activity Level',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.7)),
            ),
          ),
          const SizedBox(height: 32),

          // Primary Calories Goal display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'DAILY TARGET CALORIES',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_caloriesGoal.toStringAsFixed(0)} kcal',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Macros display in grid
          Row(
            children: [
              Expanded(
                child: _buildMacroBlock(
                  label: 'Protein',
                  val: '${_proteinGoal.toStringAsFixed(0)}g',
                  color: AppColors.primary,
                  icon: Icons.fitness_center_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroBlock(
                  label: 'Carbs',
                  val: '${_carbsGoal.toStringAsFixed(0)}g',
                  color: AppColors.accent,
                  icon: Icons.cookie_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroBlock(
                  label: 'Fat',
                  val: '${_fatGoal.toStringAsFixed(0)}g',
                  color: AppColors.accentPurple,
                  icon: Icons.opacity_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroBlock(
                  label: 'Water',
                  val: '${_waterGoal.toStringAsFixed(1)}L',
                  color: Colors.blueAccent,
                  icon: Icons.water_drop_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Technical Details (BMR, TDEE)
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated BMR', style: TextStyle(color: AppColors.textSecondary)),
                    Text('${_bmr.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated TDEE', style: TextStyle(color: AppColors.textSecondary)),
                    Text('${_tdee.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBlock({required String label, required String val, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }
}

