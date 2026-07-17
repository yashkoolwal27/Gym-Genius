import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/nutrition_api_service.dart';
import '../../widgets/shared_widgets.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _firestoreService = FirestoreService();
  final _apiService = NutritionApiService();
  
  final _nameController = TextEditingController();
  final _prepNotesController = TextEditingController();
  final _servingCountController = TextEditingController(text: '1');

  final List<RecipeIngredient> _ingredients = [];
  bool _isSaving = false;

  double get _totalCalories => _ingredients.fold(0.0, (sum, item) => sum + item.calories);
  double get _totalProtein => _ingredients.fold(0.0, (sum, item) => sum + item.protein);
  double get _totalCarbs => _ingredients.fold(0.0, (sum, item) => sum + item.carbs);
  double get _totalFat => _ingredients.fold(0.0, (sum, item) => sum + item.fat);

  void _addIngredientSheet() {
    List<FoodItem> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Ingredient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search food...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (val) async {
                      setModalState(() => isSearching = true);
                      final results = await _apiService.searchFoods(val);
                      setModalState(() {
                        searchResults = results;
                        isSearching = false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isSearching)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final food = searchResults[index];
                          return ListTile(
                            title: Text(food.name, style: const TextStyle(color: AppColors.textPrimary)),
                            subtitle: Text('${food.servingSize} • ${food.calories.toStringAsFixed(0)} kcal', style: const TextStyle(color: AppColors.textSecondary)),
                            trailing: const Icon(Icons.add, color: AppColors.primary),
                            onTap: () {
                              Navigator.pop(context);
                              _selectQuantityAndAdd(food);
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
      },
    );
  }

  void _selectQuantityAndAdd(FoodItem food) {
    final qtyController = TextEditingController(text: '1.0');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Add ${food.name}'),
        content: TextField(
          controller: qtyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantity (Multipliers of ${food.servingSize})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 1.0;
              setState(() {
                _ingredients.add(RecipeIngredient(
                  foodId: food.id,
                  foodName: food.name,
                  quantity: qty,
                  servingUnit: food.servingSize,
                  calories: food.calories * qty,
                  protein: food.protein * qty,
                  carbs: food.carbs * qty,
                  fat: food.fat * qty,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecipe() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    final count = int.tryParse(_servingCountController.text) ?? 1;

    final recipe = Recipe(
      id: const Uuid().v4(),
      userId: '', // populated inside FirestoreService
      name: _nameController.text.trim(),
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500', // default fallback template
      servingCount: count,
      prepNotes: _prepNotesController.text.trim(),
      ingredients: _ingredients,
      totalCalories: _totalCalories / count,
      totalProtein: _totalProtein / count,
      totalCarbs: _totalCarbs / count,
      totalFat: _totalFat / count,
      isTemplate: false,
    );

    try {
      await _firestoreService.addRecipe(recipe);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe created successfully! 🍳'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recipe: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _prepNotesController.dispose();
    _servingCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.primary),
            onPressed: _isSaving ? null : _saveRecipe,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Recipe Name', hintText: 'e.g. Mass Gainer Protein Shake'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _servingCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Serving Count', hintText: '1'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(), // spacing placeholder
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Ingredients'),
                TextButton.icon(
                  onPressed: _addIngredientSheet,
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: const Text('Add Ingredient', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_ingredients.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No ingredients added yet.', style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              AppCard(
                child: Column(
                  children: _ingredients.map((ing) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(ing.foodName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${ing.quantity.toStringAsFixed(1)} x ${ing.servingUnit}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                        onPressed: () {
                          setState(() {
                            _ingredients.remove(ing);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Preparation Notes'),
            const SizedBox(height: 12),
            TextField(
              controller: _prepNotesController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Enter step-by-step cooking/preparation notes here...'),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Nutrition Calculations (Total)'),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryMiniLabel(label: 'Calories', val: '${_totalCalories.toStringAsFixed(0)} kcal', color: AppColors.primary),
                  _SummaryMiniLabel(label: 'Protein', val: '${_totalProtein.toStringAsFixed(1)}g', color: AppColors.primaryBright),
                  _SummaryMiniLabel(label: 'Carbs', val: '${_totalCarbs.toStringAsFixed(1)}g', color: AppColors.accent),
                  _SummaryMiniLabel(label: 'Fat', val: '${_totalFat.toStringAsFixed(1)}g', color: AppColors.accentOrange),
                ],
              ),
            ),
            const SizedBox(height: 40),
            GradientButton(
              text: 'Save Recipe',
              onPressed: _isSaving ? null : _saveRecipe,
              isLoading: _isSaving,
              icon: Icons.check,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMiniLabel extends StatelessWidget {
  final String label;
  final String val;
  final Color color;
  const _SummaryMiniLabel({required this.label, required this.val, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}
