import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class ProgressPhotosScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const ProgressPhotosScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen> {
  final _firestoreService = FirestoreService();
  late UserProfile _currentProfile;

  String _selectedPose = 'Front'; // Front, Side, Back
  bool _isSaving = false;

  // Mock list of photo entries to make it look exactly like Layout 4 in Image 1!
  final Map<String, List<Map<String, String>>> _photoHistory = {
    'Front': [
      {'date': '15 Jan 2026', 'weight': '70.0 kg', 'url': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&q=80'},
      {'date': '15 Feb 2026', 'weight': '71.4 kg', 'url': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&q=80'},
      {'date': '15 Mar 2026', 'weight': '72.5 kg', 'url': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&q=80'},
    ],
    'Side': [
      {'date': '15 Jan 2026', 'weight': '70.0 kg', 'url': 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400&q=80'},
      {'date': '15 Feb 2026', 'weight': '71.4 kg', 'url': 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=400&q=80'},
    ],
    'Back': [
      {'date': '15 Jan 2026', 'weight': '70.0 kg', 'url': 'https://images.unsplash.com/photo-1605296867304-46d5465a25f1?w=400&q=80'},
    ],
  };

  int _selectedPhotoIdx = 2; // Default to latest

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _loadProgressPhotos();
  }

  void _loadProgressPhotos() {
    final photos = _currentProfile.progressPhotos;
    if (photos['frontPhotoUrl'] != null && photos['frontPhotoUrl'].toString().trim().isNotEmpty) {
      _photoHistory['Front']!.add({
        'date': 'Today',
        'weight': '${_currentProfile.weight.toStringAsFixed(1)} kg',
        'url': photos['frontPhotoUrl'],
      });
    }
    if (photos['sidePhotoUrl'] != null && photos['sidePhotoUrl'].toString().trim().isNotEmpty) {
      _photoHistory['Side']!.add({
        'date': 'Today',
        'weight': '${_currentProfile.weight.toStringAsFixed(1)} kg',
        'url': photos['sidePhotoUrl'],
      });
    }
    if (photos['backPhotoUrl'] != null && photos['backPhotoUrl'].toString().trim().isNotEmpty) {
      _photoHistory['Back']!.add({
        'date': 'Today',
        'weight': '${_currentProfile.weight.toStringAsFixed(1)} kg',
        'url': photos['backPhotoUrl'],
      });
    }
    
    // Set active selection to latest image of the category
    _selectedPhotoIdx = _photoHistory[_selectedPose]!.length - 1;
  }

  Future<void> _addNewPhoto() async {
    final urlController = TextEditingController();
    final weightController = TextEditingController(text: _currentProfile.weight.toString());

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
              Text('Add New $_selectedPose Photo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Photo URL',
                  hintText: 'https://example.com/photo.jpg',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Current Weight (kg)',
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Add Photo',
                onPressed: () async {
                  final url = urlController.text.trim();
                  if (url.isEmpty) return;

                  Navigator.pop(context);
                  setState(() => _isSaving = true);

                  final photos = Map<String, dynamic>.from(_currentProfile.progressPhotos);
                  if (_selectedPose == 'Front') photos['frontPhotoUrl'] = url;
                  if (_selectedPose == 'Side') photos['sidePhotoUrl'] = url;
                  if (_selectedPose == 'Back') photos['backPhotoUrl'] = url;

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
                    connectedDevices: _currentProfile.connectedDevices,
                    notifications: _currentProfile.notifications,
                    progressPhotos: photos,
                  );

                  try {
                    await _firestoreService.saveUserProfile(updatedProfile);
                    widget.onProfileUpdated(updatedProfile);
                    setState(() {
                      _currentProfile = updatedProfile;
                      _photoHistory[_selectedPose]!.add({
                        'date': 'Today',
                        'weight': '${weightController.text} kg',
                        'url': url,
                      });
                      _selectedPhotoIdx = _photoHistory[_selectedPose]!.length - 1;
                      _isSaving = false;
                    });
                  } catch (e) {
                    setState(() => _isSaving = false);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeList = _photoHistory[_selectedPose]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progress Photos', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Segmented tabs (Front, Side, Back)
            Row(
              children: ['Front', 'Side', 'Back'].map((pose) {
                final isSelected = _selectedPose == pose;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPose = pose;
                        _selectedPhotoIdx = _photoHistory[pose]!.length - 1;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          pose,
                          style: TextStyle(
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Horizontal Photo Cards View
            if (activeList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No photos uploaded yet for this pose.', style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: activeList.length,
                  itemBuilder: (context, idx) {
                    final item = activeList[idx];
                    final isSelected = idx == _selectedPhotoIdx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPhotoIdx = idx),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12, bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image
                              Expanded(
                                child: Image.network(
                                  item['url']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppColors.cardBg2,
                                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                              // Date & Weight
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                child: Column(
                                  children: [
                                    Text(
                                      item['date']!,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['weight']!,
                                      style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // "+ Add New Photo" button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _addNewPhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBg,
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Add New Photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tips Box
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tips_and_updates_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                        SizedBox(height: 6),
                        Text(
                          'Take photos in the same lighting, same pose and same location for best results.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
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
}
