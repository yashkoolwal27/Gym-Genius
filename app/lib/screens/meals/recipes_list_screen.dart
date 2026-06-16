import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';
import 'recipe_details_screen.dart';
import 'create_recipe_screen.dart';

class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({super.key});

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  
  late TabController _tabController;
  String _searchQuery = '';

  // Built-in Premium Recipe Templates for onboarding content
  final List<Recipe> _popularTemplates = [
    Recipe(
      id: 'template_mass_gainer',
      userId: 'system',
      name: 'Mass Gainer Shake',
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500',
      servingCount: 1,
      prepNotes: 'Blend all ingredients together until smooth. Add ice if desired.',
      ingredients: [
        RecipeIngredient(foodId: 'local_oats', foodName: 'Oats (Raw)', quantity: 1.0, servingUnit: '80g', calories: 303.0, protein: 10.8, carbs: 54.0, fat: 5.3),
        RecipeIngredient(foodId: 'local_chana', foodName: 'Roasted Chana', quantity: 1.0, servingUnit: '50g', calories: 184.0, protein: 10.2, carbs: 28.5, fat: 3.1),
        RecipeIngredient(foodId: 'local_whey', foodName: 'Whey Protein', quantity: 1.0, servingUnit: '30g', calories: 120.0, protein: 24.0, carbs: 3.0, fat: 1.5),
        RecipeIngredient(foodId: 'local_banana', foodName: 'Banana', quantity: 1.0, servingUnit: '1 medium', calories: 105.0, protein: 1.3, carbs: 27.0, fat: 0.3),
        RecipeIngredient(foodId: 'local_milk', foodName: 'Milk', quantity: 1.0, servingUnit: '250ml', calories: 120.0, protein: 8.0, carbs: 12.0, fat: 4.5),
      ],
      totalCalories: 832.0,
      totalProtein: 54.3,
      totalCarbs: 124.5,
      totalFat: 14.4,
      isTemplate: true,
    ),
    Recipe(
      id: 'template_protein_pancake',
      userId: 'system',
      name: 'Protein Oats Pancake',
      imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500',
      servingCount: 1,
      prepNotes: 'Mash banana, mix with oats, egg, whey, and milk. Cook on a hot pan.',
      ingredients: [
        RecipeIngredient(foodId: 'local_oats', foodName: 'Oats (Raw)', quantity: 0.5, servingUnit: '40g', calories: 151.5, protein: 5.4, carbs: 27.0, fat: 2.65),
        RecipeIngredient(foodId: 'local_banana', foodName: 'Banana', quantity: 0.5, servingUnit: '0.5 medium', calories: 52.5, protein: 0.65, carbs: 13.5, fat: 0.15),
        RecipeIngredient(foodId: 'local_egg', foodName: 'Egg', quantity: 1.0, servingUnit: '1 large', calories: 78.0, protein: 6.3, carbs: 0.6, fat: 5.3),
        RecipeIngredient(foodId: 'local_whey', foodName: 'Whey Protein', quantity: 0.7, servingUnit: '20g', calories: 84.0, protein: 16.8, carbs: 2.1, fat: 1.05),
      ],
      totalCalories: 366.0,
      totalProtein: 29.15,
      totalCarbs: 43.2,
      totalFat: 9.15,
      isTemplate: true,
    ),
    Recipe(
      id: 'template_pb_smoothie',
      userId: 'system',
      name: 'Peanut Butter Smoothie',
      imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=500',
      servingCount: 1,
      prepNotes: 'Blend milk, peanut butter, banana, and protein powder.',
      ingredients: [
        RecipeIngredient(foodId: 'local_peanut_butter', foodName: 'Peanut Butter', quantity: 2.0, servingUnit: '2 tbsp (32g)', calories: 190.0, protein: 8.0, carbs: 6.0, fat: 16.0),
        RecipeIngredient(foodId: 'local_banana', foodName: 'Banana', quantity: 1.0, servingUnit: '1 medium', calories: 105.0, protein: 1.3, carbs: 27.0, fat: 0.3),
        RecipeIngredient(foodId: 'local_milk', foodName: 'Milk', quantity: 1.0, servingUnit: '250ml', calories: 120.0, protein: 8.0, carbs: 12.0, fat: 4.5),
      ],
      totalCalories: 415.0,
      totalProtein: 17.3,
      totalCarbs: 45.0,
      totalFat: 20.8,
      isTemplate: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateRecipeScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(text: 'My Recipes'),
              Tab(text: 'Popular Templates'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyRecipesTab(),
                _buildPopularTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRecipesTab() {
    return StreamBuilder<List<Recipe>>(
      stream: _firestoreService.getRecipesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final list = snapshot.data ?? [];
        final filteredList = list
            .where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (filteredList.isEmpty) {
          return const EmptyState(
            icon: Icons.restaurant_menu,
            title: 'No custom recipes found',
            subtitle: 'Tap "+" in the top right to create your first recipe.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final rec = filteredList[index];
            return _RecipeListCard(recipe: rec);
          },
        );
      },
    );
  }

  Widget _buildPopularTab() {
    final filteredTemplates = _popularTemplates
        .where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTemplates.length,
      itemBuilder: (context, index) {
        return _RecipeListCard(recipe: filteredTemplates[index]);
      },
    );
  }
}

class _RecipeListCard extends StatelessWidget {
  final Recipe recipe;
  const _RecipeListCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsScreen(recipe: recipe),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                recipe.imageUrl.isNotEmpty ? recipe.imageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.cardBg2,
                  child: const Icon(Icons.restaurant, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(
                    '${recipe.totalCalories.toStringAsFixed(0)} kcal  •  P: ${recipe.totalProtein.toStringAsFixed(0)}g  •  C: ${recipe.totalCarbs.toStringAsFixed(0)}g  •  F: ${recipe.totalFat.toStringAsFixed(0)}g',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
