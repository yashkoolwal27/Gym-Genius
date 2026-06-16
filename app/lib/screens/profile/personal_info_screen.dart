import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const PersonalInfoScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _firestoreService = FirestoreService();
  late UserProfile _currentProfile;

  String _name = '';
  String _dob = '';
  String _gender = 'Male';
  String _email = '';
  String _phone = '';
  String _country = 'India';
  String _city = 'Indore';
  String _language = 'English';
  double _height = 170.0;
  double _weight = 70.0;
  bool _isSaving = false;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer Not To Say'];

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _loadData();
  }

  void _loadData() {
    _name = _currentProfile.name;
    _gender = _currentProfile.basicProfile['gender'] ?? 'Male';
    _height = _currentProfile.height;
    _weight = _currentProfile.weight;
    _email = _currentProfile.email;

    final personal = _currentProfile.personalInfo;
    _dob = personal['dob'] ?? '16 May 2003';
    _phone = personal['phone'] ?? '+91 98765 43210';
    _country = personal['country'] ?? 'India';
    _city = personal['city'] ?? 'Indore';
    _language = personal['language'] ?? 'English';
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);

    final updatedBasic = Map<String, dynamic>.from(_currentProfile.basicProfile);
    updatedBasic['name'] = _name;
    updatedBasic['gender'] = _gender;
    updatedBasic['height'] = _height;
    updatedBasic['weight'] = _weight;

    final updatedPersonal = Map<String, dynamic>.from(_currentProfile.personalInfo);
    updatedPersonal['dob'] = _dob;
    updatedPersonal['phone'] = _phone;
    updatedPersonal['country'] = _country;
    updatedPersonal['city'] = _city;
    updatedPersonal['language'] = _language;

    final updatedProfile = UserProfile(
      uid: _currentProfile.uid,
      email: _currentProfile.email,
      onboardingCompleted: _currentProfile.onboardingCompleted,
      basicProfile: updatedBasic,
      goals: _currentProfile.goals,
      personalInfo: updatedPersonal,
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
          const SnackBar(content: Text('Personal info updated successfully! ✅'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: _saveData,
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildEditableRow('Full Name', _name, Icons.person_outline_rounded, Colors.blueAccent, () => _editSingleField('Full Name', _name, (v) => setState(() => _name = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('Date of Birth', _dob, Icons.calendar_today_rounded, Colors.orangeAccent, () => _editSingleField('Date of Birth', _dob, (v) => setState(() => _dob = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('Gender', _gender, Icons.wc_rounded, Colors.greenAccent, () => _showGenderPicker()),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('Email', _email, Icons.email_outlined, Colors.redAccent, () {}, isEditable: false),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('Phone Number', _phone, Icons.phone_android_rounded, Colors.tealAccent, () => _editSingleField('Phone Number', _phone, (v) => setState(() => _phone = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('Country', _country, Icons.public_rounded, Colors.purpleAccent, () => _editSingleField('Country', _country, (v) => setState(() => _country = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('City', _city, Icons.location_city_rounded, Colors.amberAccent, () => _editSingleField('City', _city, (v) => setState(() => _city = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('Language', _language, Icons.language_rounded, Colors.pinkAccent, () => _editSingleField('Language', _language, (v) => setState(() => _language = v))),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('Height', '${_height.round()} cm', Icons.height_rounded, Colors.greenAccent, () => _editSingleField('Height (cm)', _height.toString(), (v) {
                    final d = double.tryParse(v);
                    if (d != null) setState(() => _height = d);
                  })),
                  const Divider(height: 1, color: AppColors.border),
                  _buildEditableRow('Weight', '${_weight.toStringAsFixed(1)} kg', Icons.monitor_weight_outlined, Colors.blueAccent, () => _editSingleField('Weight (kg)', _weight.toString(), (v) {
                    final d = double.tryParse(v);
                    if (d != null) setState(() => _weight = d);
                  })),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: GradientButton(
                text: 'Save Personal Info',
                onPressed: _isSaving ? null : _saveData,
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

  Widget _buildEditableRow(String label, String value, IconData icon, Color color, VoidCallback onTap, {bool isEditable = true}) {
    return ListTile(
      onTap: isEditable ? onTap : null,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          if (isEditable)
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20)
          else
            const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 16),
        ],
      ),
    );
  }

  void _editSingleField(String label, String currentVal, ValueChanged<String> onSaved) {
    final controller = TextEditingController(text: currentVal);
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
              Text('Edit $label', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: label,
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Save Info',
                onPressed: () {
                  onSaved(controller.text.trim());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGenderPicker() {
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
              const Text('Select Gender', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _genders.length,
                  itemBuilder: (context, idx) {
                    final g = _genders[idx];
                    return ListTile(
                      title: Text(g, style: const TextStyle(color: AppColors.textPrimary)),
                      trailing: g == _gender ? const Icon(Icons.check, color: AppColors.primary) : null,
                      onTap: () {
                        setState(() => _gender = g);
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
