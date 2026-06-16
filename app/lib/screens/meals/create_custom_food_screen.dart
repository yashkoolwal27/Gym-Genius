import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';
import 'food_details_screen.dart';

class CreateCustomFoodScreen extends StatefulWidget {
  final String initialMealType;
  const CreateCustomFoodScreen({super.key, required this.initialMealType});

  @override
  State<CreateCustomFoodScreen> createState() => _CreateCustomFoodScreenState();
}

class _CreateCustomFoodScreenState extends State<CreateCustomFoodScreen> {
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  File? _pickedImage;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Take Photo (Camera)', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Choose from Gallery', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Controllers for basic fields
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100g');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController(text: '0.0');
  final _sugarController = TextEditingController(text: '0.0');
  final _sodiumController = TextEditingController(text: '0.0');
  final _imageUrlController = TextEditingController();

  // Controllers for Vitamins (% DV)
  final _vitAController = TextEditingController(text: '0.0');
  final _vitCController = TextEditingController(text: '0.0');
  final _vitDController = TextEditingController(text: '0.0');
  final _vitEController = TextEditingController(text: '0.0');
  final _vitB6Controller = TextEditingController(text: '0.0');
  final _vitB12Controller = TextEditingController(text: '0.0');
  final _calciumController = TextEditingController(text: '0.0');
  final _ironController = TextEditingController(text: '0.0');
  final _zincController = TextEditingController(text: '0.0');

  // Controllers for Amino Acids (g)
  final _leucineController = TextEditingController(text: '0.0');
  final _isoleucineController = TextEditingController(text: '0.0');
  final _valineController = TextEditingController(text: '0.0');
  final _glutamineController = TextEditingController(text: '0.0');
  final _arginineController = TextEditingController(text: '0.0');
  final _lysineController = TextEditingController(text: '0.0');

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _imageUrlController.dispose();

    _vitAController.dispose();
    _vitCController.dispose();
    _vitDController.dispose();
    _vitEController.dispose();
    _vitB6Controller.dispose();
    _vitB12Controller.dispose();
    _calciumController.dispose();
    _ironController.dispose();
    _zincController.dispose();

    _leucineController.dispose();
    _isoleucineController.dispose();
    _valineController.dispose();
    _glutamineController.dispose();
    _arginineController.dispose();
    _lysineController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Build micronutrient map
    final micros = <String, double>{};
    void addMicroIfGreaterZero(String key, String valueStr) {
      final val = double.tryParse(valueStr) ?? 0.0;
      if (val > 0) {
        micros[key] = val;
      }
    }

    addMicroIfGreaterZero('Vitamin A', _vitAController.text);
    addMicroIfGreaterZero('Vitamin C', _vitCController.text);
    addMicroIfGreaterZero('Vitamin D', _vitDController.text);
    addMicroIfGreaterZero('Vitamin E', _vitEController.text);
    addMicroIfGreaterZero('Vitamin B6', _vitB6Controller.text);
    addMicroIfGreaterZero('Vitamin B12', _vitB12Controller.text);
    addMicroIfGreaterZero('Calcium', _calciumController.text);
    addMicroIfGreaterZero('Iron', _ironController.text);
    addMicroIfGreaterZero('Zinc', _zincController.text);

    addMicroIfGreaterZero('Leucine', _leucineController.text);
    addMicroIfGreaterZero('Isoleucine', _isoleucineController.text);
    addMicroIfGreaterZero('Valine', _valineController.text);
    addMicroIfGreaterZero('Glutamine', _glutamineController.text);
    addMicroIfGreaterZero('Arginine', _arginineController.text);
    addMicroIfGreaterZero('Lysine', _lysineController.text);

    final foodId = 'custom_${const Uuid().v4()}';
    String finalImageUrl = _imageUrlController.text.trim();

    if (_pickedImage != null) {
      try {
        finalImageUrl = await _firestoreService.uploadFoodImage(foodId, _pickedImage!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e'), backgroundColor: AppColors.error),
          );
        }
        setState(() => _isSaving = false);
        return;
      }
    }

    final newFood = FoodItem(
      id: foodId,
      name: _nameController.text.trim(),
      servingSize: _servingSizeController.text.trim(),
      calories: double.tryParse(_caloriesController.text) ?? 0.0,
      protein: double.tryParse(_proteinController.text) ?? 0.0,
      carbs: double.tryParse(_carbsController.text) ?? 0.0,
      fat: double.tryParse(_fatController.text) ?? 0.0,
      fiber: double.tryParse(_fiberController.text) ?? 0.0,
      sugar: double.tryParse(_sugarController.text) ?? 0.0,
      sodium: double.tryParse(_sodiumController.text) ?? 0.0,
      imageUrl: finalImageUrl,
      micronutrients: micros,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    try {
      await _firestoreService.addCustomFood(newFood);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom Food Item Saved! 🍏'),
            backgroundColor: AppColors.success,
          ),
        );
        // Replace current screen directly with the new food details screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailsScreen(
              food: newFood,
              mealType: widget.initialMealType,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save food: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Custom Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: _isSaving ? null : _saveCustomFood,
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Basic Info'),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Food Name *',
                              hintText: 'e.g. Greek Yogurt',
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Please enter a name' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _servingSizeController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Serving Size *',
                              hintText: 'e.g. 100g, 1 cup, 1 piece',
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Please enter serving size' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _imageUrlController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Image URL (Optional Fallback)',
                              hintText: 'https://...',
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _showImageSourceSheet,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: _pickedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(_pickedImage!, fit: BoxFit.cover),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 36),
                                        SizedBox(height: 8),
                                        Text(
                                          'Capture/Upload Photo (Camera or Gallery)',
                                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Replaces / overwrites existing food photo',
                                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Macronutrients'),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _caloriesController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Calories (kcal) *',
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _proteinController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Protein (g) *',
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _carbsController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Carbs (g) *',
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _fatController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Fat (g) *',
                                  ),
                                  validator: (val) =>
                                      val == null || val.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Other Nutrients (Optional)'),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _fiberController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Fiber (g)',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _sugarController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Sugar (g)',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _sodiumController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Sodium (mg)',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const SectionHeader(title: 'Micronutrients (Optional)'),
                        children: [
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Vitamins & Minerals (% DV)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          AppCard(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _vitAController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Vitamin A'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _vitCController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Vitamin C'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _vitDController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Vitamin D'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _vitEController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Vitamin E'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _vitB6Controller,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Vitamin B6'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _vitB12Controller,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Vitamin B12'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _calciumController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Calcium'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _ironController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Iron'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _zincController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(labelText: 'Zinc'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Amino Acids Profile (g)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          AppCard(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _leucineController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Leucine'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _isoleucineController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Isoleucine'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _valineController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Valine'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _glutamineController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Glutamine'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _arginineController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Arginine'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lysineController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(labelText: 'Lysine'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    GradientButton(
                      text: 'Save Custom Food',
                      onPressed: _isSaving ? null : _saveCustomFood,
                      isLoading: _isSaving,
                      icon: Icons.check,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
