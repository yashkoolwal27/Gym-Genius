import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const SettingsScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  late UserProfile _currentProfile;

  bool _smartWatch = false;
  bool _fitnessBand = false;
  bool _smartScale = false;
  bool _googleFit = false;
  bool _appleHealth = false;
  bool _samsungHealth = false;

  bool _workoutReminder = false;
  bool _mealReminder = false;
  bool _waterReminder = false;
  bool _sleepReminder = false;
  bool _photoReminder = false;
  bool _customReminder = false;

  String _selectedUnit = 'Metric (kg, cm)';
  String _selectedTheme = 'Dark';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _loadSettings();
  }

  void _loadSettings() async {
    final devices = _currentProfile.connectedDevices;
    _smartWatch = devices['smartWatch'] ?? false;
    _fitnessBand = devices['fitnessBand'] ?? false;
    _smartScale = devices['smartScale'] ?? false;
    _googleFit = devices['googleFit'] ?? false;
    _appleHealth = devices['appleHealth'] ?? false;
    _samsungHealth = devices['samsungHealth'] ?? false;

    final notifs = _currentProfile.notifications;
    _workoutReminder = notifs['workoutReminder'] ?? false;
    _mealReminder = notifs['mealReminder'] ?? false;
    _waterReminder = notifs['waterReminder'] ?? false;
    _sleepReminder = notifs['sleepReminder'] ?? false;
    _photoReminder = notifs['progressPhotoReminder'] ?? notifs['photoReminder'] ?? false;
    _customReminder = notifs['customReminder'] ?? false;
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final updatedProfile = UserProfile(
      uid: _currentProfile.uid,
      email: _currentProfile.email,
      onboardingCompleted: _currentProfile.onboardingCompleted,
      basicProfile: _currentProfile.basicProfile,
      goals: _currentProfile.goals,
      personalInfo: _currentProfile.personalInfo,
      advancedMetrics: _currentProfile.advancedMetrics,
      healthInfo: _currentProfile.healthInfo,
      gymInfo: _currentProfile.gymInfo,
      aiPreferences: _currentProfile.aiPreferences,
      connectedDevices: {
        'smartWatch': _smartWatch,
        'fitnessBand': _fitnessBand,
        'smartScale': _smartScale,
        'googleFit': _googleFit,
        'appleHealth': _appleHealth,
        'samsungHealth': _samsungHealth,
      },
      notifications: {
        'workoutReminder': _workoutReminder,
        'mealReminder': _mealReminder,
        'waterReminder': _waterReminder,
        'sleepReminder': _sleepReminder,
        'progressPhotoReminder': _photoReminder,
        'customReminder': _customReminder,
      },
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
          const SnackBar(content: Text('Settings saved successfully! ✅'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: _saveSettings,
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Account Section
            _buildSettingsGroup('Account', [
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Account Settings',
                subtitle: 'Manage email, security & data',
                color: Colors.blueAccent,
                onTap: () {},
              ),
            ]),


            // Connected Devices Section
            _buildSettingsGroup('Connected Devices', [
              _buildToggleTile('Smart Watch', _smartWatch, (val) => setState(() => _smartWatch = val)),
              _buildToggleTile('Fitness Band', _fitnessBand, (val) => setState(() => _fitnessBand = val)),
              _buildToggleTile('Smart Scale', _smartScale, (val) => setState(() => _smartScale = val)),
              _buildToggleTile('Google Fit / Apple Health', _googleFit, (val) => setState(() => _googleFit = val)),
            ]),
            const SizedBox(height: 16),

            // Notifications Section
            _buildSettingsGroup('Notifications & Reminders', [
              _buildToggleTile('Workout Reminders', _workoutReminder, (val) => setState(() => _workoutReminder = val)),
              _buildToggleTile('Meal Log Reminders', _mealReminder, (val) => setState(() => _mealReminder = val)),
              _buildToggleTile('Water Log Reminders', _waterReminder, (val) => setState(() => _waterReminder = val)),
              _buildToggleTile('Progress Photo Reminders', _photoReminder, (val) => setState(() => _photoReminder = val)),
            ]),
            const SizedBox(height: 16),

            // General preferences
            _buildSettingsGroup('Preferences', [
              _buildSettingsTile(
                icon: Icons.grid_3x3_rounded,
                title: 'Units',
                subtitle: _selectedUnit,
                color: Colors.greenAccent,
                onTap: () => _showUnitSelector(),
              ),
              _buildSettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: _selectedTheme,
                color: Colors.purpleAccent,
                onTap: () => _showThemeSelector(),
              ),
              _buildSettingsTile(
                icon: Icons.ios_share_rounded,
                title: 'Data Export',
                subtitle: 'Download your raw workout & nutrition data',
                color: Colors.orangeAccent,
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // Log Out Button
            AppCard(
              onTap: () {
                _authService.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(tiles.length, (index) {
              if (index == tiles.length - 1) return tiles[index];
              return Column(
                children: [
                  tiles[index],
                  const Divider(height: 1, color: AppColors.border),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
    );
  }

  Widget _buildToggleTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
      activeThumbColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  void _showUnitSelector() {
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
              const Text('Select Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Metric (kg, cm)', style: TextStyle(color: AppColors.textPrimary)),
                trailing: _selectedUnit.contains('Metric') ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedUnit = 'Metric (kg, cm)');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Imperial (lbs, ft-in)', style: TextStyle(color: AppColors.textPrimary)),
                trailing: _selectedUnit.contains('Imperial') ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedUnit = 'Imperial (lbs, ft-in)');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeSelector() {
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
              const Text('Select Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Dark Mode (Premium)', style: TextStyle(color: AppColors.textPrimary)),
                trailing: _selectedTheme == 'Dark' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedTheme = 'Dark');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Light Mode (Standard)', style: TextStyle(color: AppColors.textPrimary)),
                trailing: _selectedTheme == 'Light' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedTheme = 'Light');
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
