import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'firestore_service.dart';


class NutritionApiService {
  // Free USDA API endpoint using the default rate-limited DEMO_KEY
  static const String _usdaUrl = 'https://api.nal.usda.gov/fdc/v1/foods/search';
  static const String _usdaApiKey = 'DEMO_KEY';

  // OpenFoodFacts search url
  static const String _offUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  // Curated high-quality image URLs for consistent, beautiful UI rendering
  static const Map<String, String> _foodImages = {
    'roti': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=500&auto=format&fit=crop&q=80',
    'paneer': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80',
    'dal': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80',
    'oat milk': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=80',
    'oats': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=500&auto=format&fit=crop&q=80',
    'oat': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=500&auto=format&fit=crop&q=80',
    'chana': 'https://images.unsplash.com/photo-1541832676-9b763b0239ab?w=500&auto=format&fit=crop&q=80',
    'banana': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=80',
    'milk': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=80',
    'chicken': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500&auto=format&fit=crop&q=80',
    'egg': 'https://images.unsplash.com/photo-1516401270372-e5ea4007775a?w=500&auto=format&fit=crop&q=80',
    'rice': 'https://images.unsplash.com/photo-1536304997881-a372c179924b?w=500&auto=format&fit=crop&q=80',
    'apple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=80',
    'sabzi': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&auto=format&fit=crop&q=80',
    'salad': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&auto=format&fit=crop&q=80',
    'smoothie': 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=500&auto=format&fit=crop&q=80',
    'shake': 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80',
    'peanut butter': 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=500&auto=format&fit=crop&q=80',
    'default': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80',
  };

  // Local fallback database of standard Indian and gym-friendly foods
  static final List<FoodItem> _localFoodDb = [
    FoodItem(
      id: 'local_roti',
      name: 'Roti (Whole Wheat)',
      servingSize: '1 piece (35g)',
      calories: 85.0,
      protein: 3.0,
      carbs: 18.0,
      fat: 0.4,
      fiber: 2.5,
      sugar: 0.1,
      sodium: 5.0,
      micronutrients: const {
        'Iron': 8.0,
        'Calcium': 2.0,
        'Vitamin B6': 5.0,
        'Leucine': 0.2,
        'Valine': 0.1,
        'Glutamine': 0.8,
      },
      imageUrl: _foodImages['roti']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_paneer',
      name: 'Paneer (Raw)',
      servingSize: '100g',
      calories: 265.0,
      protein: 18.3,
      carbs: 1.2,
      fat: 20.8,
      fiber: 0.0,
      sugar: 0.2,
      sodium: 18.0,
      micronutrients: const {
        'Calcium': 40.0,
        'Vitamin A': 10.0,
        'Vitamin D': 5.0,
        'Leucine': 1.6,
        'Isoleucine': 1.0,
        'Valine': 1.1,
        'Glutamine': 2.2,
        'Arginine': 0.6,
      },
      imageUrl: _foodImages['paneer']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_dal',
      name: 'Moong Dal (Cooked)',
      servingSize: '1 cup (150g)',
      calories: 147.0,
      protein: 8.2,
      carbs: 23.5,
      fat: 2.1,
      fiber: 5.4,
      sugar: 0.4,
      sodium: 210.0,
      micronutrients: const {
        'Iron': 15.0,
        'Calcium': 4.0,
        'Vitamin C': 2.0,
        'Vitamin B6': 8.0,
        'Leucine': 0.6,
        'Valine': 0.4,
        'Glutamine': 1.2,
      },
      imageUrl: _foodImages['dal']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_oats',
      name: 'Oats (Raw)',
      servingSize: '1 cup (80g)',
      calories: 303.0,
      protein: 10.8,
      carbs: 54.0,
      fat: 5.3,
      fiber: 8.0,
      sugar: 1.1,
      sodium: 2.0,
      micronutrients: const {
        'Iron': 20.0,
        'Calcium': 4.0,
        'Vitamin B6': 10.0,
        'Zinc': 15.0,
        'Leucine': 0.8,
        'Isoleucine': 0.4,
        'Valine': 0.5,
        'Glutamine': 1.5,
      },
      imageUrl: _foodImages['oats']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_chana',
      name: 'Roasted Chana',
      servingSize: '50g',
      calories: 184.0,
      protein: 10.2,
      carbs: 28.5,
      fat: 3.1,
      fiber: 4.8,
      sugar: 1.2,
      sodium: 8.0,
      micronutrients: const {
        'Iron': 12.0,
        'Calcium': 6.0,
        'Vitamin B6': 15.0,
        'Leucine': 0.7,
        'Valine': 0.5,
        'Glutamine': 1.4,
      },
      imageUrl: _foodImages['chana']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_banana',
      name: 'Banana',
      servingSize: '1 medium (118g)',
      calories: 105.0,
      protein: 1.3,
      carbs: 27.0,
      fat: 0.3,
      fiber: 3.1,
      sugar: 14.4,
      sodium: 1.0,
      micronutrients: const {
        'Vitamin C': 15.0,
        'Vitamin B6': 20.0,
        'Potassium': 10.0,
        'Leucine': 0.1,
        'Glutamine': 0.2,
      },
      imageUrl: _foodImages['banana']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_milk',
      name: 'Milk (Cow, Semi-Skimmed)',
      servingSize: '1 cup (250ml)',
      calories: 120.0,
      protein: 8.0,
      carbs: 12.0,
      fat: 4.5,
      fiber: 0.0,
      sugar: 11.5,
      sodium: 105.0,
      micronutrients: const {
        'Calcium': 30.0,
        'Vitamin D': 25.0,
        'Vitamin B12': 18.0,
        'Vitamin A': 10.0,
        'Leucine': 0.8,
        'Isoleucine': 0.5,
        'Valine': 0.6,
        'Glutamine': 1.4,
      },
      imageUrl: _foodImages['milk']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_chicken',
      name: 'Chicken Breast (Grilled)',
      servingSize: '100g',
      calories: 165.0,
      protein: 31.0,
      carbs: 0.0,
      fat: 3.6,
      fiber: 0.0,
      sugar: 0.0,
      sodium: 74.0,
      micronutrients: const {
        'Vitamin B6': 30.0,
        'Vitamin B12': 10.0,
        'Iron': 6.0,
        'Zinc': 8.0,
        'Leucine': 2.6,
        'Isoleucine': 1.6,
        'Valine': 1.5,
        'Glutamine': 4.5,
        'Arginine': 1.9,
        'Lysine': 2.4,
      },
      imageUrl: _foodImages['chicken']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_egg',
      name: 'Boiled Egg',
      servingSize: '1 large (50g)',
      calories: 78.0,
      protein: 6.3,
      carbs: 0.6,
      fat: 5.3,
      fiber: 0.0,
      sugar: 0.5,
      sodium: 62.0,
      micronutrients: const {
        'Vitamin D': 11.0,
        'Vitamin B12': 15.0,
        'Vitamin A': 8.0,
        'Iron': 5.0,
        'Leucine': 0.5,
        'Isoleucine': 0.3,
        'Valine': 0.4,
        'Glutamine': 0.8,
        'Arginine': 0.4,
      },
      imageUrl: _foodImages['egg']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_rice',
      name: 'Basmati Rice (Cooked)',
      servingSize: '1 cup (158g)',
      calories: 205.0,
      protein: 4.2,
      carbs: 44.5,
      fat: 0.4,
      fiber: 0.6,
      sugar: 0.1,
      sodium: 5.0,
      micronutrients: const {
        'Iron': 2.0,
        'Vitamin B6': 2.0,
        'Leucine': 0.3,
        'Valine': 0.2,
        'Glutamine': 0.5,
      },
      imageUrl: _foodImages['rice']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_apple',
      name: 'Apple',
      servingSize: '1 medium (182g)',
      calories: 95.0,
      protein: 0.5,
      carbs: 25.0,
      fat: 0.3,
      fiber: 4.4,
      sugar: 19.0,
      sodium: 2.0,
      micronutrients: const {
        'Vitamin C': 8.0,
        'Vitamin A': 2.0,
        'Vitamin B6': 5.0,
        'Leucine': 0.05,
      },
      imageUrl: _foodImages['apple']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_peanut_butter',
      name: 'Peanut Butter',
      servingSize: '1 tbsp (16g)',
      calories: 95.0,
      protein: 4.0,
      carbs: 3.0,
      fat: 8.0,
      fiber: 1.0,
      sugar: 1.5,
      sodium: 75.0,
      micronutrients: const {
        'Vitamin E': 15.0,
        'Vitamin B6': 10.0,
        'Zinc': 8.0,
        'Leucine': 0.3,
        'Valine': 0.2,
        'Glutamine': 0.7,
        'Arginine': 0.6,
      },
      imageUrl: _foodImages['peanut butter']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_whey',
      name: 'Whey Protein (Standard)',
      servingSize: '1 scoop (30g)',
      calories: 120.0,
      protein: 24.0,
      carbs: 3.0,
      fat: 1.5,
      fiber: 0.0,
      sugar: 1.0,
      sodium: 60.0,
      micronutrients: const {
        'Calcium': 15.0,
        'Vitamin D': 4.0,
        'Leucine': 2.5,
        'Isoleucine': 1.5,
        'Valine': 1.4,
        'Glutamine': 4.0,
        'Arginine': 0.6,
        'Lysine': 2.2,
      },
      imageUrl: _foodImages['shake']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_aloo_paratha',
      name: 'Aloo Paratha',
      servingSize: '1 paratha (100g)',
      calories: 290.0,
      protein: 5.5,
      carbs: 42.0,
      fat: 11.2,
      fiber: 4.1,
      imageUrl: _foodImages['roti']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_veg_biryani',
      name: 'Veg Biryani',
      servingSize: '1 plate (250g)',
      calories: 380.0,
      protein: 7.5,
      carbs: 58.0,
      fat: 13.5,
      fiber: 4.5,
      imageUrl: _foodImages['rice']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_chicken_biryani',
      name: 'Chicken Biryani',
      servingSize: '1 plate (300g)',
      calories: 520.0,
      protein: 28.0,
      carbs: 54.0,
      fat: 21.0,
      fiber: 3.0,
      imageUrl: _foodImages['rice']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_dal_tadka',
      name: 'Dal Tadka',
      servingSize: '1 katori (150g)',
      calories: 150.0,
      protein: 7.8,
      carbs: 20.0,
      fat: 4.5,
      fiber: 4.2,
      imageUrl: _foodImages['dal']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_chhole',
      name: 'Chhole / Chana Masala',
      servingSize: '1 katori (180g)',
      calories: 240.0,
      protein: 10.5,
      carbs: 34.0,
      fat: 7.0,
      fiber: 8.0,
      imageUrl: _foodImages['chana']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_masala_dosa',
      name: 'Masala Dosa',
      servingSize: '1 dosa (150g)',
      calories: 280.0,
      protein: 5.8,
      carbs: 44.0,
      fat: 9.0,
      fiber: 3.5,
      imageUrl: _foodImages['default']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_idli',
      name: 'Idli (Steamed)',
      servingSize: '2 idlis (100g)',
      calories: 130.0,
      protein: 4.2,
      carbs: 26.0,
      fat: 0.8,
      fiber: 1.5,
      imageUrl: _foodImages['default']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_poha',
      name: 'Poha',
      servingSize: '1 plate (150g)',
      calories: 220.0,
      protein: 3.8,
      carbs: 38.0,
      fat: 6.2,
      fiber: 2.5,
      imageUrl: _foodImages['default']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_samosa',
      name: 'Samosa',
      servingSize: '1 samosa (80g)',
      calories: 260.0,
      protein: 4.2,
      carbs: 32.0,
      fat: 13.0,
      fiber: 2.0,
      imageUrl: _foodImages['default']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_gulab_jamun',
      name: 'Gulab Jamun',
      servingSize: '1 piece (50g)',
      calories: 175.0,
      protein: 2.2,
      carbs: 26.0,
      fat: 7.0,
      fiber: 0.2,
      imageUrl: _foodImages['default']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_butter_chicken',
      name: 'Butter Chicken',
      servingSize: '1 portion (200g)',
      calories: 390.0,
      protein: 26.0,
      carbs: 10.0,
      fat: 28.0,
      fiber: 1.5,
      imageUrl: _foodImages['chicken']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_paneer_butter_masala',
      name: 'Paneer Butter Masala',
      servingSize: '1 katori (180g)',
      calories: 340.0,
      protein: 13.5,
      carbs: 12.0,
      fat: 27.0,
      fiber: 2.0,
      imageUrl: _foodImages['paneer']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_rajma',
      name: 'Rajma Masala',
      servingSize: '1 katori (180g)',
      calories: 225.0,
      protein: 10.0,
      carbs: 33.0,
      fat: 5.8,
      fiber: 7.5,
      imageUrl: _foodImages['chana']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_butter_naan',
      name: 'Butter Naan',
      servingSize: '1 naan (90g)',
      calories: 310.0,
      protein: 8.0,
      carbs: 48.0,
      fat: 9.5,
      fiber: 2.1,
      imageUrl: _foodImages['roti']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_pav_bhaji',
      name: 'Pav Bhaji',
      servingSize: '2 pavs + bhaji (250g)',
      calories: 420.0,
      protein: 8.5,
      carbs: 58.0,
      fat: 17.5,
      fiber: 6.0,
      imageUrl: _foodImages['sabzi']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_soya_chunks',
      name: 'Soya Chunks',
      servingSize: '50g dry',
      calories: 170.0,
      protein: 26.0,
      carbs: 16.5,
      fat: 0.5,
      fiber: 6.5,
      imageUrl: _foodImages['default']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
    FoodItem(
      id: 'local_momos',
      name: 'Veg Steamed Momos',
      servingSize: '6 pieces (120g)',
      calories: 190.0,
      protein: 4.8,
      carbs: 34.0,
      fat: 3.8,
      fiber: 2.0,
      imageUrl: _foodImages['default']!,
      lastUpdated: DateTime.now().toIso8601String(),
    ),
  ];

  static String getFoodImage(String name) {
    final lower = name.toLowerCase();
    for (final key in _foodImages.keys) {
      if (lower.contains(key) && key != 'default') {
        return _foodImages[key]!;
      }
    }
    return _foodImages['default']!;
  }

  static List<ServingMeasure> parseServings(String servingSizeText) {
    final List<ServingMeasure> servings = [];
    servings.add(ServingMeasure(name: '100g', grams: 100.0, multiplier: 1.0));

    final String text = servingSizeText.trim();
    if (text.isEmpty || 
        text.toLowerCase() == '100g' || 
        text.toLowerCase() == '100 g' || 
        text.toLowerCase() == '100ml' || 
        text.toLowerCase() == '100 ml') {
      return servings;
    }

    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:g|ml|G|ML)');
    final match = regex.firstMatch(text);
    if (match != null) {
      final grams = double.tryParse(match.group(1) ?? '') ?? 100.0;
      if (grams > 0 && (grams - 100.0).abs() > 0.01) {
        String name = text;
        if (text.contains('(')) {
          name = text.split('(').first.trim();
        }
        if (name.isEmpty) {
          name = text;
        }
        servings.add(ServingMeasure(name: name, grams: grams, multiplier: grams / 100.0));
      }
    } else {
      if (text.isNotEmpty) {
        servings.add(ServingMeasure(name: text, grams: 100.0, multiplier: 1.0));
      }
    }
    return servings;
  }

  static List<FoodItem> _jsonFoodDb = [];

  static Future<void> loadAssetFoodDatabase() async {
    if (_jsonFoodDb.isNotEmpty) return;
    try {
      final jsonString = await rootBundle.loadString('assets/json/master_indian_foods_db.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List items = data['items'] ?? [];
      _jsonFoodDb = items.map((item) {
        final String name = item['name'] ?? '';
        final String serving = item['servingUnit'] ?? '100g';
        return FoodItem(
          id: item['foodId'] ?? 'food_${name.toLowerCase().replaceAll(' ', '_')}',
          name: name,
          servingSize: serving,
          calories: (item['calories'] as num?)?.toDouble() ?? 0.0,
          protein: (item['protein'] as num?)?.toDouble() ?? 0.0,
          carbs: (item['carbs'] as num?)?.toDouble() ?? 0.0,
          fat: (item['fat'] as num?)?.toDouble() ?? 0.0,
          fiber: (item['fiber'] as num?)?.toDouble() ?? 0.0,
          imageUrl: item['imageUrl'] ?? getFoodImage(name),
          lastUpdated: DateTime.now().toIso8601String(),
          servings: parseServings(serving),
        );
      }).toList();
    } catch (_) {}
  }

  // Strict Fallback Search Query (Master DB -> Custom Foods -> USDA -> OpenFoodFacts)
  Future<List<FoodItem>> searchFoods(String query) async {
    if (query.trim().isEmpty) return [];

    final List<FoodItem> rawResults = [];
    final firestoreService = FirestoreService();

    // Fetch global image overrides
    final overrides = await firestoreService.getGlobalFoodOverrides();

    // Load master 1,284 asset database
    await loadAssetFoodDatabase();

    // 1. Search 1,284 items master asset JSON database
    final jsonMatches = _jsonFoodDb
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (jsonMatches.isNotEmpty) {
      rawResults.addAll(jsonMatches);
    }

    // 2. Search foods_master on Firestore
    try {
      final masterSnap = await FirebaseFirestore.instance
          .collection('foods_master')
          .where('searchKeywords', arrayContains: query.toLowerCase().trim())
          .limit(10)
          .get();
      for (final doc in masterSnap.docs) {
        rawResults.add(FoodItem.fromMap(doc.data()));
      }
    } catch (_) {}

    // 3. Search local DB
    final localMatches = _localFoodDb
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (localMatches.isNotEmpty) {
      final mappedLocal = localMatches.map((food) {
        if (overrides.containsKey(food.id)) {
          return FoodItem(
            id: food.id,
            name: food.name,
            servingSize: food.servingSize,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fat: food.fat,
            fiber: food.fiber,
            sugar: food.sugar,
            sodium: food.sodium,
            micronutrients: food.micronutrients,
            imageUrl: overrides[food.id]!,
            lastUpdated: food.lastUpdated,
            servings: food.servings,
          );
        }
        return food;
      }).toList();
      rawResults.addAll(mappedLocal);
    }

    // 3. Search custom_foods (Firestore DB)
    final customFoods = await firestoreService.getCustomFoods();
    final customMatches = customFoods
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (customMatches.isNotEmpty) {
      final mappedCustom = customMatches.map((food) {
        if (overrides.containsKey(food.id)) {
          return FoodItem(
            id: food.id,
            name: food.name,
            servingSize: food.servingSize,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fat: food.fat,
            fiber: food.fiber,
            sugar: food.sugar,
            sodium: food.sodium,
            micronutrients: food.micronutrients,
            imageUrl: overrides[food.id]!,
            lastUpdated: food.lastUpdated,
            servings: food.servings,
          );
        }
        return food;
      }).toList();
      rawResults.addAll(mappedCustom);
    }

    // 4. Fallback: USDA API Search (only if Tier 1 & Tier 2 returned nothing)
    if (rawResults.isEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$_usdaUrl?query=$query&api_key=$_usdaApiKey&pageSize=10'),
        ).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final foods = data['foods'] as List<dynamic>? ?? [];
          for (final f in foods) {
            final name = f['description'] as String;
            final serving = f['servingSize'] != null
                ? '${f['servingSize']}${f['servingSizeUnit'] ?? 'g'}'
                : '100g';
            
            double kcal = 0, p = 0, c = 0, f_fat = 0, fib = 0, sug = 0, sod = 0;
            final nutrients = f['foodNutrients'] as List<dynamic>? ?? [];
            for (final nut in nutrients) {
              final id = nut['nutrientId'];
              final val = (nut['value'] as num?)?.toDouble() ?? 0.0;
              if (id == 1008) kcal = val;
              else if (id == 1003) p = val;
              else if (id == 1005) c = val;
              else if (id == 1004) f_fat = val;
              else if (id == 1079) fib = val;
              else if (id == 2000) sug = val;
              else if (id == 1093) sod = val;
            }

            final foodId = 'usda_${f['fdcId'] ?? const Uuid().v4()}';
            rawResults.add(FoodItem(
              id: foodId,
              name: name,
              servingSize: serving,
              calories: kcal,
              protein: p,
              carbs: c,
              fat: f_fat,
              fiber: fib,
              sugar: sug,
              sodium: sod,
              imageUrl: overrides[foodId] ?? getFoodImage(name),
              lastUpdated: DateTime.now().toIso8601String(),
              servings: parseServings(serving),
            ));
          }
        }
      } catch (_) {}
    }

    // 5. Fallback: OpenFoodFacts Search (only if all previous tiers returned nothing)
    if (rawResults.isEmpty) {
      try {
        final response = await http.get(
          Uri.parse('$_offUrl?search_terms=$query&search_simple=1&action=process&json=1'),
        ).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final products = data['products'] as List<dynamic>? ?? [];
          for (final p in products) {
            final name = p['product_name'] ?? 'Unknown product';
            final serving = p['serving_size'] ?? '100g';
            final nut = p['nutriments'] ?? {};
            
            double kcal = (nut['energy-kcal_100g'] as num?)?.toDouble() ?? 0.0;
            double prot = (nut['proteins_100g'] as num?)?.toDouble() ?? 0.0;
            double carbs = (nut['carbohydrates_100g'] as num?)?.toDouble() ?? 0.0;
            double fat = (nut['fat_100g'] as num?)?.toDouble() ?? 0.0;
            double fiber = (nut['fiber_100g'] as num?)?.toDouble() ?? 0.0;
            double sugar = (nut['sugars_100g'] as num?)?.toDouble() ?? 0.0;
            double sodium = (nut['sodium_100g'] as num?)?.toDouble() ?? 0.0;

            final foodId = 'off_${p['_id'] ?? const Uuid().v4()}';
            rawResults.add(FoodItem(
              id: foodId,
              name: name,
              servingSize: serving,
              calories: kcal,
              protein: prot,
              carbs: carbs,
              fat: fat,
              fiber: fiber,
              sugar: sugar,
              sodium: sodium,
              imageUrl: overrides[foodId] ?? (p['image_front_small_url'] ?? getFoodImage(name)),
              lastUpdated: DateTime.now().toIso8601String(),
              servings: parseServings(serving),
            ));
          }
        }
      } catch (_) {}
    }

    // Deduplicate list by core name key (case-insensitive)
    final Set<String> seenNames = {};
    final List<FoodItem> uniqueResults = [];
    for (final item in rawResults) {
      String coreName = item.name.toLowerCase();
      coreName = coreName.replaceAll(RegExp(r'\([^)]*\)'), '');
      coreName = coreName.replaceAll(RegExp(r'[,.\-]'), ' ');
      coreName = coreName.replaceAll(
        RegExp(r'\b(raw|dry|cooked|boiled|fresh|whole|wheat|organic|bowl|cup|spoon|rolled|sliced|diced|cooked)\b'),
        ' ',
      );
      coreName = coreName.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (coreName.isEmpty) {
        coreName = item.name.toLowerCase().trim();
      }

      if (!seenNames.contains(coreName)) {
        seenNames.add(coreName);
        uniqueResults.add(item);
      }
    }

    return uniqueResults;
  }
}
