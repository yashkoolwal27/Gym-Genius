import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _fitnessGoal = 'Weight Loss';
  String _activityLevel = 'Moderate';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _firestoreService.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _heightController.text = profile.height.toString();
        _weightController.text = profile.weight.toString();
        _fitnessGoal = profile.fitnessGoal;
        _activityLevel = profile.activityLevel;
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final profile = UserProfile(
      uid: _authService.currentUser!.uid,
      name: _nameController.text,
      email: _authService.currentUser!.email!,
      age: int.tryParse(_ageController.text) ?? 25,
      height: double.tryParse(_heightController.text) ?? 170.0,
      weight: double.tryParse(_weightController.text) ?? 70.0,
      fitnessGoal: _fitnessGoal,
      activityLevel: _activityLevel,
    );
    await _firestoreService.saveUserProfile(profile);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully! ✅'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.surface,
                                child: Icon(Icons.person, size: 60, color: AppColors.textMuted),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.camera_alt, size: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(labelText: 'Display Name'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(labelText: 'Age'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(labelText: 'Height (cm)'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(labelText: 'Current Weight (kg)'),
                        ),
                        const SizedBox(height: 24),
                        const Text('Fitness Goal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _fitnessGoal,
                          dropdownColor: AppColors.cardBg,
                          items: AppConstants.fitnessGoals.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _fitnessGoal = v!),
                        ),
                        const SizedBox(height: 32),
                        GradientButton(
                          text: 'Update Profile',
                          onPressed: _isSaving ? null : _saveProfile,
                          isLoading: _isSaving,
                          icon: Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    onTap: () => _authService.signOut(),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.error),
                        const SizedBox(width: 16),
                        Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                        Spacer(),
                        Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
