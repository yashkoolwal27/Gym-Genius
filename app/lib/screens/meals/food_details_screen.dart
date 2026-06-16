import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared_widgets.dart';
import 'add_to_meal_screen.dart';

class FoodDetailsScreen extends StatefulWidget {
  final FoodItem food;
  final String mealType;
  const FoodDetailsScreen({super.key, required this.food, required this.mealType});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final _firestoreService = FirestoreService();
  bool _isFavorite = false;
  bool _isAdmin = false;
  bool _isImageLoading = false;
  String _currentImageUrl = '';

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.food.imageUrl;
    _checkFavorite();
    _checkAdmin();
  }

  Future<void> _checkFavorite() async {
    final fav = await _firestoreService.isFoodFavorite(widget.food.id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _checkAdmin() async {
    final admin = await _firestoreService.checkIfAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

  Future<void> _toggleFavorite() async {
    await _firestoreService.toggleFavoriteFood(widget.food);
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to Favorites! ⭐' : 'Removed from Favorites.'),
        backgroundColor: AppColors.cardBg,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showEditImageDialog(String foodId) {
    final controller = TextEditingController(text: _currentImageUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Update Product Image', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://images.unsplash.com/...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              Navigator.pop(context);
              setState(() => _isImageLoading = true);
              try {
                await _firestoreService.updateGlobalFoodImage(foodId, newUrl);
                if (mounted) {
                  setState(() {
                    _currentImageUrl = newUrl;
                    _isImageLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product image updated successfully! 📸'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isImageLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update image: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final grams = _parseGrams(food.servingSize);
    final factor = 100.0 / grams;

    final calories100g = food.calories * factor;
    final protein100g = food.protein * factor;
    final carbs100g = food.carbs * factor;
    final fat100g = food.fat * factor;
    final fiber100g = food.fiber * factor;
    final sugar100g = food.sugar * factor;
    final sodium100g = food.sodium * factor;

    final vitamins = <String, double>{};
    final aminoAcids = <String, double>{};
    final aminoAcidNames = [
      'leucine', 'isoleucine', 'valine', 'glutamine', 'arginine', 'lysine',
      'alanine', 'aspartic acid', 'glutamic acid', 'glycine', 'histidine',
      'methionine', 'phenylalanine', 'proline', 'serine', 'threonine',
      'tryptophan', 'tyrosine'
    ];

    food.micronutrients.forEach((key, val) {
      if (aminoAcidNames.contains(key.toLowerCase().trim())) {
        aminoAcids[key] = val;
      } else {
        vitamins[key] = val;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? AppColors.warning : AppColors.textPrimary,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              background: Hero(
                tag: 'food_img_${food.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _currentImageUrl.isNotEmpty ? _currentImageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardBg2,
                        child: const Icon(Icons.restaurant, size: 60, color: AppColors.textMuted),
                      ),
                    ),
                    if (_isImageLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      ),
                    if (_isAdmin)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton.small(
                          heroTag: 'edit_img_btn',
                          backgroundColor: AppColors.primary,
                          onPressed: () => _showEditImageDialog(food.id),
                          child: const Icon(Icons.edit, color: Colors.black),
                        ),
                      ),
                  ],
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
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Normalized Serving', style: TextStyle(color: AppColors.textSecondary)),
                            Text('100g (Original: ${food.servingSize})', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Calories per 100g', style: TextStyle(color: AppColors.textSecondary)),
                            Text('${calories100g.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Macronutrients (per 100g)'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _MacroProgressRing(label: 'Protein', value: protein100g, total: 50, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _MacroProgressRing(label: 'Carbs', value: carbs100g, total: 100, color: AppColors.accent)),
                      const SizedBox(width: 12),
                      Expanded(child: _MacroProgressRing(label: 'Fat', value: fat100g, total: 30, color: AppColors.accentOrange)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Other Nutrients (per 100g)'),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _NutrientRow(label: 'Dietary Fiber', value: '${fiber100g.toStringAsFixed(1)} g'),
                        const Divider(color: AppColors.border),
                        _NutrientRow(label: 'Sugar', value: '${sugar100g.toStringAsFixed(1)} g'),
                        const Divider(color: AppColors.border),
                        _NutrientRow(label: 'Sodium', value: '${sodium100g.toStringAsFixed(0)} mg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Micronutrients (per 100g)'),
                  const SizedBox(height: 12),
                  if (food.micronutrients.isEmpty)
                    AppCard(
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Micronutrients data not available.', style: TextStyle(color: AppColors.textMuted)),
                        ),
                      ),
                    )
                  else ...[
                    if (vitamins.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4),
                        child: Text('Vitamins & Minerals', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ),
                      AppCard(
                        child: Column(
                          children: vitamins.entries.map((e) {
                            final valNormalized = e.value * factor;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.key, style: const TextStyle(color: AppColors.textSecondary)),
                                  Text('${valNormalized.toStringAsFixed(1)}% DV', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (aminoAcids.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4),
                        child: Text('Amino Acids Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ),
                      AppCard(
                        child: Column(
                          children: aminoAcids.entries.map((e) {
                            final valNormalized = e.value * factor;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.key, style: const TextStyle(color: AppColors.textSecondary)),
                                  Text('${valNormalized.toStringAsFixed(2)} g', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accent)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddToMealScreen(food: food, initialMealType: widget.mealType),
              ),
            );
          },
          icon: Icons.add,
        ),
      ),
    );
  }
}

class _MacroProgressRing extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;
  const _MacroProgressRing({required this.label, required this.value, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    double pct = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 5,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text('${value.toStringAsFixed(0)}g', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final String label;
  final String value;
  const _NutrientRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
