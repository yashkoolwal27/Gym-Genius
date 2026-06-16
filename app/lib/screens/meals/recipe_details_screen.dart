import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final _firestoreService = FirestoreService();
  String _selectedMeal = 'Breakfast';
  bool _isLogging = false;

  void _showAddMealSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Recipe to Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedMeal,
                    dropdownColor: AppColors.cardBg,
                    decoration: const InputDecoration(labelText: 'Select Meal Type'),
                    items: const [
                      DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                      DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                      DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                      DropdownMenuItem(value: 'Snacks', child: Text('Snacks')),
                    ],
                    onChanged: (val) => setModalState(() => _selectedMeal = val!),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: _isLogging ? 'Adding...' : 'Add to Meal',
                    isLoading: _isLogging,
                    onPressed: () async {
                      setModalState(() => _isLogging = true);
                      await _logRecipeToMeal();
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logRecipeToMeal() async {
    final now = DateTime.now();
    final timestamp = now.toIso8601String();
    
    try {
      // Log each ingredient as a MealEntry
      for (final ing in widget.recipe.ingredients) {
        final entry = MealEntry(
          id: const Uuid().v4(),
          userId: '', 
          foodId: ing.foodId,
          foodName: ing.foodName,
          mealType: _selectedMeal,
          quantity: ing.quantity,
          servingUnit: ing.servingUnit,
          calories: ing.calories,
          protein: ing.protein,
          carbs: ing.carbs,
          fat: ing.fat,
          timestamp: timestamp,
        );
        await _firestoreService.addMealEntry(entry);
      }
      
      // Update streaks
      await _firestoreService.updateAndGetStreak();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe logged to meal successfully! 🍽️'), backgroundColor: AppColors.success),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log recipe: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _deleteRecipe() async {
    await _firestoreService.deleteRecipe(widget.recipe.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe deleted'), backgroundColor: AppColors.error),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              if (!recipe.isTemplate)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: _deleteRecipe,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              background: Image.network(
                recipe.imageUrl.isNotEmpty ? recipe.imageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.cardBg2,
                  child: const Icon(Icons.restaurant, size: 60, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Nutrition Banner
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MacroSummaryLabel(label: 'Calories', value: '${recipe.totalCalories.toStringAsFixed(0)} kcal', color: AppColors.primary),
                        _MacroSummaryLabel(label: 'Protein', value: '${recipe.totalProtein.toStringAsFixed(0)}g', color: AppColors.primaryBright),
                        _MacroSummaryLabel(label: 'Carbs', value: '${recipe.totalCarbs.toStringAsFixed(0)}g', color: AppColors.accent),
                        _MacroSummaryLabel(label: 'Fat', value: '${recipe.totalFat.toStringAsFixed(0)}g', color: AppColors.accentOrange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Ingredients'),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: recipe.ingredients.map((ing) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ing.foodName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ),
                              Text(
                                '${ing.quantity.toStringAsFixed(1)} x ${ing.servingUnit} (${ing.calories.toStringAsFixed(0)} kcal)',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Preparation Notes'),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Text(
                      recipe.prepNotes.isNotEmpty ? recipe.prepNotes : 'No preparation notes provided for this recipe.',
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.background,
        child: GradientButton(
          text: 'Add to Meal',
          onPressed: _showAddMealSheet,
          icon: Icons.add_circle_outline,
        ),
      ),
    );
  }
}

class _MacroSummaryLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroSummaryLabel({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
      ],
    );
  }
}
