import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class AddToMealScreen extends StatefulWidget {
  final FoodItem food;
  final String initialMealType;
  const AddToMealScreen({super.key, required this.food, required this.initialMealType});

  @override
  State<AddToMealScreen> createState() => _AddToMealScreenState();
}

class _AddToMealScreenState extends State<AddToMealScreen> {
  final _firestoreService = FirestoreService();
  final _quantityController = TextEditingController(text: '1.0');
  
  late String _selectedMeal;
  late TimeOfDay _selectedTime;
  String _selectedUnit = 'g';
  double _quantity = 1.0;
  bool _isSaving = false;
  String _mockPhotoPath = '';

  String _getMealTypeFromTime(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 11) {
      return 'Breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'Lunch';
    } else if (hour >= 16 && hour < 19) {
      return 'Snacks';
    } else if (hour >= 19 && hour < 23) {
      return 'Dinner';
    } else {
      return 'Snacks';
    }
  }

  TimeOfDay _getInitialTimeForMeal(String mealType) {
    final now = TimeOfDay.now();
    final currentMeal = _getMealTypeFromTime(now);
    if (currentMeal == mealType) {
      return now;
    }
    switch (mealType) {
      case 'Breakfast':
        return const TimeOfDay(hour: 8, minute: 0);
      case 'Lunch':
        return const TimeOfDay(hour: 13, minute: 0);
      case 'Snacks':
        return const TimeOfDay(hour: 16, minute: 30);
      case 'Dinner':
        return const TimeOfDay(hour: 20, minute: 0);
      default:
        return now;
    }
  }

  IconData _getMealIcon(String meal) {
    switch (meal) {
      case 'Breakfast':
        return Icons.free_breakfast_outlined;
      case 'Lunch':
        return Icons.lunch_dining_outlined;
      case 'Dinner':
        return Icons.dinner_dining_outlined;
      case 'Snacks':
      default:
        return Icons.cookie_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedTime = _getInitialTimeForMeal(widget.initialMealType);
    _selectedMeal = _getMealTypeFromTime(_selectedTime);
    
    // Auto-detect unit. If base serving is piece, medium, or scoop, default to 'pcs'
    final servingLower = widget.food.servingSize.toLowerCase();
    if (servingLower.contains('piece') || servingLower.contains('medium') || servingLower.contains('scoop')) {
      _selectedUnit = 'pcs';
      _quantity = 1.0;
    } else {
      _selectedUnit = 'g';
      _quantity = _parseGrams(widget.food.servingSize);
    }

    _quantityController.text = _quantity == _quantity.toInt()
        ? _quantity.toInt().toString()
        : _quantity.toStringAsFixed(1);

    _quantityController.addListener(() {
      final val = double.tryParse(_quantityController.text);
      if (val != null && val >= 0) {
        setState(() => _quantity = val);
      }
    });
  }

  double _parseGrams(String servingSize) {
    final lower = servingSize.toLowerCase().trim();
    
    // First, look for grams (e.g. 100g, 100 g, (80g))
    final gRegex = RegExp(r'(\d+(?:\.\d+)?)\s*g\b');
    final gMatch = gRegex.firstMatch(lower);
    if (gMatch != null) {
      return double.tryParse(gMatch.group(1)!) ?? 100.0;
    }

    // Look for ml (assuming 1ml = 1g for liquids)
    final mlRegex = RegExp(r'(\d+(?:\.\d+)?)\s*ml\b');
    final mlMatch = mlRegex.firstMatch(lower);
    if (mlMatch != null) {
      return double.tryParse(mlMatch.group(1)!) ?? 100.0;
    }

    // Look for oz (ounce)
    final ozRegex = RegExp(r'(\d+(?:\.\d+)?)\s*oz\b');
    final ozMatch = ozRegex.firstMatch(lower);
    if (ozMatch != null) {
      final ozVal = double.tryParse(ozMatch.group(1)!) ?? 0.0;
      if (ozVal > 0) return ozVal * 28.35;
    }

    // Look for kg
    final kgRegex = RegExp(r'(\d+(?:\.\d+)?)\s*kg\b');
    final kgMatch = kgRegex.firstMatch(lower);
    if (kgMatch != null) {
      final kgVal = double.tryParse(kgMatch.group(1)!) ?? 0.0;
      if (kgVal > 0) return kgVal * 1000.0;
    }

    return 100.0;
  }

  void _convertQuantity(String oldUnit, String newUnit) {
    final baseGrams = _parseGrams(widget.food.servingSize);
    final currentVal = double.tryParse(_quantityController.text) ?? 1.0;
    
    double grams;
    final oldCustom = widget.food.servings.firstWhere(
      (s) => s.name == oldUnit,
      orElse: () => ServingMeasure(name: '', grams: 0.0, multiplier: 0.0),
    );
    if (oldCustom.name.isNotEmpty) {
      grams = currentVal * oldCustom.grams;
    } else if (oldUnit == 'g') {
      grams = currentVal;
    } else if (oldUnit == 'kg') {
      grams = currentVal * 1000.0;
    } else { // 'pcs'
      grams = currentVal * baseGrams;
    }
    
    double newVal;
    final newCustom = widget.food.servings.firstWhere(
      (s) => s.name == newUnit,
      orElse: () => ServingMeasure(name: '', grams: 0.0, multiplier: 0.0),
    );
    if (newCustom.name.isNotEmpty) {
      newVal = newCustom.grams > 0 ? grams / newCustom.grams : 1.0;
    } else if (newUnit == 'g') {
      newVal = grams;
    } else if (newUnit == 'kg') {
      newVal = grams / 1000.0;
    } else { // 'pcs'
      newVal = grams / baseGrams;
    }
    
    String textVal;
    if (newUnit == 'kg') {
      textVal = newVal.toStringAsFixed(3);
    } else if (newUnit == 'g') {
      textVal = newVal.toStringAsFixed(0);
    } else {
      textVal = newVal.toStringAsFixed(1);
      if (textVal.endsWith('.0')) {
        textVal = textVal.substring(0, textVal.length - 2);
      }
    }
    
    _quantityController.text = textVal;
    setState(() {
      _selectedUnit = newUnit;
      _quantity = newVal;
    });
  }

  double get _multiplier {
    final customMatch = widget.food.servings.firstWhere(
      (s) => s.name == _selectedUnit,
      orElse: () => ServingMeasure(name: '', grams: 0.0, multiplier: 1.0),
    );
    if (customMatch.name.isNotEmpty) {
      return _quantity * customMatch.multiplier;
    }

    final baseGrams = _parseGrams(widget.food.servingSize);
    if (_selectedUnit == 'g') {
      return _quantity / baseGrams;
    } else if (_selectedUnit == 'kg') {
      return (_quantity * 1000.0) / baseGrams;
    } else {
      return _quantity;
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedMeal = _getMealTypeFromTime(picked);
      });
    }
  }

  void _simulateCapturePhoto() {
    setState(() => _mockPhotoPath = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal Photo Captured! 📸 (Vision ready)'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    
    final now = DateTime.now();
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
    final timestamp = '${DateFormat('yyyy-MM-dd').format(now)}T$timeStr';

    final entry = MealEntry(
      id: const Uuid().v4(),
      userId: '',
      foodId: widget.food.id,
      foodName: widget.food.name,
      mealType: _selectedMeal,
      quantity: _quantity,
      servingUnit: _selectedUnit,
      calories: widget.food.calories * _multiplier,
      protein: widget.food.protein * _multiplier,
      carbs: widget.food.carbs * _multiplier,
      fat: widget.food.fat * _multiplier,
      fiber: widget.food.fiber * _multiplier,
      sugar: widget.food.sugar * _multiplier,
      sodium: widget.food.sodium * _multiplier,
      imageUrl: widget.food.imageUrl,
      photoUrl: _mockPhotoPath,
      timestamp: timestamp,
    );

    try {
      await _firestoreService.addMealEntry(entry);
      await _firestoreService.updateAndGetStreak();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal logged successfully! 🍽️'), backgroundColor: AppColors.success),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save meal: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final calories = food.calories * _multiplier;
    final protein = food.protein * _multiplier;
    final carbs = food.carbs * _multiplier;
    final fat = food.fat * _multiplier;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add to Meal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      food.imageUrl.isNotEmpty ? food.imageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Base serving size: ${food.servingSize}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _getMealIcon(_selectedMeal),
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Meal Category: ',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  Text(
                    _selectedMeal,
                    style: const TextStyle(
                      color: AppColors.primaryBright,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Auto-Categorized',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    dropdownColor: AppColors.cardBg,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'g', child: Text('g')),
                      const DropdownMenuItem(value: 'kg', child: Text('kg')),
                      const DropdownMenuItem(value: 'pcs', child: Text('pcs')),
                      ...widget.food.servings
                          .where((s) => s.name != 'g' && s.name != 'kg' && s.name != 'pcs' && s.name.isNotEmpty)
                          .map((s) => DropdownMenuItem(value: s.name, child: Text(s.name)))
                          .toList(),
                    ],
                    onChanged: (val) {
                      if (val != null && val != _selectedUnit) {
                        _convertQuantity(_selectedUnit, val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Time', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            ],
                          ),
                          const Icon(Icons.access_time, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Macro Preview'),
                IconButton(
                  icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                  onPressed: _simulateCapturePhoto,
                ),
              ],
            ),
            if (_mockPhotoPath.isNotEmpty) ...[
              const SizedBox(height: 8),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(_mockPhotoPath, height: 120, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            ],
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              children: [
                _PreviewMacroCard(label: 'Calories', val: calories.toStringAsFixed(0), unit: 'kcal', color: AppColors.primary),
                _PreviewMacroCard(label: 'Protein', val: protein.toStringAsFixed(1), unit: 'g', color: AppColors.primaryBright),
                _PreviewMacroCard(label: 'Carbs', val: carbs.toStringAsFixed(1), unit: 'g', color: AppColors.accent),
                _PreviewMacroCard(label: 'Fat', val: fat.toStringAsFixed(1), unit: 'g', color: AppColors.accentOrange),
              ],
            ),
            const SizedBox(height: 40),
            GradientButton(
              text: 'Save Meal Log',
              onPressed: _isSaving ? null : _save,
              isLoading: _isSaving,
              icon: Icons.check,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMacroCard extends StatelessWidget {
  final String label;
  final String val;
  final String unit;
  final Color color;
  const _PreviewMacroCard({required this.label, required this.val, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
