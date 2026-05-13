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

  // Profile data
  int _age = 25;
  double _height = 170;
  double _weight = 70;
  String _fitnessGoal = 'Muscle Gain';
  String _activityLevel = 'Moderate';

  final List<String> _goals = ['Weight Loss', 'Muscle Gain', 'Endurance', 'Flexibility', 'Maintenance'];
  final List<String> _activityLevels = ['Sedentary', 'Lightly Active', 'Moderate', 'Very Active', 'Extra Active'];

  Future<void> _completeOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = UserProfile(
      uid: user.uid,
      name: widget.name,
      email: widget.email,
      age: _age,
      height: _height,
      weight: _weight,
      fitnessGoal: _fitnessGoal,
      activityLevel: _activityLevel,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Complete Your Profile',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This helps us personalize your journey',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 20),
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    _buildAgeHeightWeight(),
                    _buildFitnessGoals(),
                    _buildActivityLevel(),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                        child: const Text('Back', style: TextStyle(color: AppColors.textSecondary)),
                      )
                    else
                      const SizedBox(),
                    
                    SizedBox(
                      width: 150,
                      child: GradientButton(
                        text: _currentPage == 2 ? 'Get Started' : 'Continue',
                        onPressed: () {
                          if (_currentPage < 2) {
                            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          } else {
                            _completeOnboarding();
                          }
                        },
                        icon: _currentPage == 2 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
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

  Widget _buildAgeHeightWeight() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSliderCard(
            title: 'How old are you?',
            value: _age.toDouble(),
            min: 15, max: 80,
            label: '$_age years',
            onChanged: (v) => setState(() => _age = v.toInt()),
          ),
          const SizedBox(height: 20),
          _buildSliderCard(
            title: 'What is your height?',
            value: _height,
            min: 140, max: 220,
            label: '${_height.toInt()} cm',
            onChanged: (v) => setState(() => _height = v),
          ),
          const SizedBox(height: 20),
          _buildSliderCard(
            title: 'Current Weight',
            value: _weight,
            min: 40, max: 150,
            label: '${_weight.toInt()} kg',
            onChanged: (v) => setState(() => _weight = v),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessGoals() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What is your primary fitness goal?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _fitnessGoal == goal;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => setState(() => _fitnessGoal = goal),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
                            color: isSelected ? AppColors.primary : Colors.transparent,
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                        ),
                        const SizedBox(width: 16),
                        Text(goal, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.w600)),
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

  Widget _buildActivityLevel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about your daily activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _activityLevels.length,
              itemBuilder: (context, index) {
                final level = _activityLevels[index];
                final isSelected = _activityLevel == level;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => setState(() => _activityLevel = level),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
                            color: isSelected ? AppColors.primary : Colors.transparent,
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                        ),
                        const SizedBox(width: 16),
                        Text(level, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.w600)),
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

  Widget _buildSliderCard({required String title, required double value, required double min, required double max, required String label, required ValueChanged<double> onChanged}) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: value,
            min: min, max: max,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
