import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

// Sub-screens navigation
import 'personal_info_screen.dart';
import 'body_measurements_screen.dart';
import 'progress_photos_screen.dart';
import 'goals_targets_screen.dart';
import 'diet_preferences_screen.dart';
import 'achievements_screen.dart';
import 'ai_health_summary_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestoreService = FirestoreService();
  bool _isLoading = true;
  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await _firestoreService.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _currentProfile = profile;
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateProfileState(UserProfile updatedProfile) {
    setState(() {
      _currentProfile = updatedProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final profile = _currentProfile ??
        UserProfile(
          uid: 'guest',
          email: 'guest@gymgenius.com',
          basicProfile: {
            'name': 'Yash Koolwal',
            'gender': 'Male',
            'age': 21,
            'height': 178.0,
            'weight': 72.5,
            'goal': 'Muscle Building',
          },
          goals: {'targetWeight': 80.0},
        );

    final completion = profile.getCompletionPercentage();
    final double healthScore = (70.0 + (completion * 0.3)).clamp(0.0, 100.0);
    final double bodyFat = (profile.advancedMetrics['bodyFat'] as num?)?.toDouble() ?? 15.2;

    // Calculate BMI
    double bmi = 0.0;
    if (profile.height > 0) {
      final hM = profile.height / 100.0;
      bmi = profile.weight / (hM * hM);
    }

    // Dynamic details string
    final detailsString = "${profile.age} Years • ${profile.basicProfile['gender'] ?? 'Male'} • Intermediate";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  profile: profile,
                  onProfileUpdated: _updateProfileState,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // User header card matching Layout 1
              _buildUserHeaderCard(profile, detailsString),
              const SizedBox(height: 16),

              // 4 Score Cards (circular metrics)
              _buildScoresGrid(healthScore, profile),
              const SizedBox(height: 16),

              // Overview Section with values
              _buildOverviewCard(profile, bodyFat, bmi),
              const SizedBox(height: 16),

              // Current Goal Card
              _buildCurrentGoalCard(profile),
              const SizedBox(height: 20),

              // Main menu/feature navigation options
              _buildNavigationMenu(profile),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeaderCard(UserProfile profile, String details) {
    final username = profile.personalInfo['username']?.toString().trim().isNotEmpty ?? false
        ? "@${profile.personalInfo['username']}"
        : "@yashkoolwal21";

    return AppCard(
      child: Row(
        children: [
          // Circular Avatar with photo URL or fallback icon
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.border,
            backgroundImage: profile.personalInfo['photoUrl'] != null &&
                    profile.personalInfo['photoUrl'].toString().trim().isNotEmpty
                ? NetworkImage(profile.personalInfo['photoUrl'])
                : null,
            child: profile.personalInfo['photoUrl'] == null ||
                    profile.personalInfo['photoUrl'].toString().trim().isEmpty
                ? const Icon(Icons.person_rounded, size: 40, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(width: 16),

          // User details labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.name.isNotEmpty ? profile.name : 'Yash Koolwal',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Pro Member',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  details,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresGrid(double healthScore, UserProfile profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: [
        _buildCircularScoreCard('Health', healthScore, AppColors.primary, profile),
        _buildCircularScoreCard('Nutrition', 92.0, AppColors.primaryBright, profile),
        _buildCircularScoreCard('Workout', 85.0, AppColors.accent, profile),
        _buildCircularScoreCard('Recovery', 76.0, AppColors.accentPurple, profile),
      ],
    );
  }

  Widget _buildCircularScoreCard(String label, double val, Color accentColor, UserProfile profile) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AIHealthSummaryScreen(profile: profile)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular gauge representation
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  value: val / 100.0,
                  strokeWidth: 3,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              Text(
                '${val.round()}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(UserProfile profile, double bodyFat, double bmi) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonalInfoScreen(
                      profile: profile,
                      onProfileUpdated: _updateProfileState,
                    ),
                  ),
                ),
                child: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewColumn('Weight', '${profile.weight.toStringAsFixed(1)} kg'),
              _buildOverviewColumn('Height', '${profile.height.round()} cm'),
              _buildOverviewColumn('Body Fat', '${bodyFat.toStringAsFixed(1)} %'),
              _buildOverviewColumn('BMI', bmi.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewColumn(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCurrentGoalCard(UserProfile profile) {
    final goal = profile.basicProfile['goal'] ?? 'Muscle Building';
    final targetWeight = (profile.goals['targetWeight'] as num?)?.toDouble() ?? 80.0;

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GoalsTargetsScreen(
            profile: profile,
            onProfileUpdated: _updateProfileState,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Goal', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('$goal (Target: ${targetWeight.toStringAsFixed(1)} kg)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu(UserProfile profile) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildMenuRow(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            color: Colors.blueAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PersonalInfoScreen(
                  profile: profile,
                  onProfileUpdated: _updateProfileState,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildMenuRow(
            icon: Icons.accessibility_new_rounded,
            title: 'Body Measurements',
            color: Colors.greenAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BodyMeasurementsScreen(
                  profile: profile,
                  onProfileUpdated: _updateProfileState,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildMenuRow(
            icon: Icons.add_a_photo_rounded,
            title: 'Progress Photos',
            color: Colors.redAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProgressPhotosScreen(
                  profile: profile,
                  onProfileUpdated: _updateProfileState,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildMenuRow(
            icon: Icons.track_changes_rounded,
            title: 'Goals & Targets',
            color: Colors.tealAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalsTargetsScreen(
                  profile: profile,
                  onProfileUpdated: _updateProfileState,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildMenuRow(
            icon: Icons.restaurant_menu_rounded,
            title: 'Diet Preferences',
            color: Colors.orangeAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DietPreferencesScreen(
                  profile: profile,
                  onProfileUpdated: _updateProfileState,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildMenuRow(
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            color: Colors.amber,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AchievementsScreen(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildMenuRow(
            icon: Icons.health_and_safety_rounded,
            title: 'AI Health Summary',
            color: Colors.pinkAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIHealthSummaryScreen(profile: profile),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
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
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
    );
  }
}
