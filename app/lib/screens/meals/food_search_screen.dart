import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/nutrition_api_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';
import 'food_details_screen.dart';
import 'recipe_details_screen.dart';
import 'create_custom_food_screen.dart';


class FoodSearchScreen extends StatefulWidget {
  final String initialMealType;
  const FoodSearchScreen({super.key, required this.initialMealType});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _apiService = NutritionApiService();
  final _firestoreService = FirestoreService();

  late TabController _tabController;
  List<FoodItem> _foods = [];
  List<Recipe> _recipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialTemplates();
  }

  Future<void> _loadInitialTemplates() async {
    // Show some popular templates or default list when empty
    setState(() => _isLoading = true);
    final results = await _apiService.searchFoods('oats');
    setState(() {
      _foods = results;
      _isLoading = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final foodResults = await _apiService.searchFoods(query);
      
      // Also query local custom recipes matching query
      // For now, load simple custom templates
      setState(() {
        _foods = foodResults;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _scanBarcode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Barcode Scanner', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'Align package barcode within the frame. (Barcode Scanner ready in Phase 1)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Mock scan Moong Dal
              _search('Moong Dal');
            },
            child: const Text('Mock Scan'),
          ),
        ],
      ),
    );
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
        title: const Text('Search Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            onPressed: _scanBarcode,
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
                hintText: 'Search Banana, Paneer, Oats, Roti...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() {}),
              onSubmitted: _search,
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Foods'),
              Tab(text: 'Recipes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(),
                _buildFoodsTab(),
                _buildRecipesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_foods.isEmpty) {
      if (_searchController.text.trim().isEmpty) {
        return const EmptyState(
          icon: Icons.search,
          title: 'Search for foods',
          subtitle: 'Enter a food item name to find nutritional facts.',
        );
      } else {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.cardBg2,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.no_food, size: 60, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Text(
                'No results for "${_searchController.text}"',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              const Text(
                'We couldn\'t find this food in our database. You can create a custom food item with your own custom nutritional values!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 30),
              GradientButton(
                text: 'Create Custom Food',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateCustomFoodScreen(initialMealType: widget.initialMealType),
                    ),
                  ).then((_) {
                    if (_searchController.text.trim().isNotEmpty) {
                      _search(_searchController.text);
                    }
                  });
                },
                icon: Icons.add,
              ),
            ],
          ),
        );
      }
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _foods.length,
      itemBuilder: (context, index) {
        final food = _foods[index];
        return _FoodListTile(food: food, mealType: widget.initialMealType);
      },
    );
  }

  Widget _buildFoodsTab() {
    return _buildAllTab();
  }

  Widget _buildRecipesTab() {
    return StreamBuilder<List<Recipe>>(
      stream: _firestoreService.getRecipesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long,
            title: 'No custom recipes found',
            subtitle: 'Go to Recipes tab to create new recipes.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final rec = list[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailsScreen(recipe: rec),
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        rec.imageUrl.isNotEmpty
                            ? rec.imageUrl
                            : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100',
                        width: 50,
                        height: 50,
                        fit: cropFit(rec.imageUrl),
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
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
                          Text(rec.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(
                            '${rec.totalCalories.toStringAsFixed(0)} kcal • P: ${rec.totalProtein.toStringAsFixed(0)}g • C: ${rec.totalCarbs.toStringAsFixed(0)}g • F: ${rec.totalFat.toStringAsFixed(0)}g',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  BoxFit cropFit(String url) => url.startsWith('http') ? BoxFit.cover : BoxFit.contain;
}

class _FoodListTile extends StatelessWidget {
  final FoodItem food;
  final String mealType;
  const _FoodListTile({required this.food, required this.mealType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailsScreen(food: food, mealType: mealType),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                food.imageUrl.isNotEmpty ? food.imageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 50,
                  height: 50,
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
                  Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${food.servingSize} • ${food.calories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
