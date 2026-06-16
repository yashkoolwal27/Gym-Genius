class ServingMeasure {
  final String name;
  final double grams;
  final double multiplier;

  ServingMeasure({
    required this.name,
    required this.grams,
    required this.multiplier,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'grams': grams,
      'multiplier': multiplier,
    };
  }

  factory ServingMeasure.fromMap(Map<String, dynamic> map) {
    return ServingMeasure(
      name: map['name'] ?? '',
      grams: (map['grams'] as num?)?.toDouble() ?? 0.0,
      multiplier: (map['multiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final String servingSize;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final Map<String, double> micronutrients;
  final String imageUrl;
  final String lastUpdated;
  final List<ServingMeasure> servings;

  FoodItem({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.micronutrients = const {},
    this.imageUrl = '',
    required this.lastUpdated,
    this.servings = const [],
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    final macros = map['macros'] as Map<dynamic, dynamic>?;

    final double caloriesVal = (macros?['calories'] ?? map['calories'] as num?)?.toDouble() ?? 0.0;
    final double proteinVal = (macros?['protein'] ?? map['protein'] as num?)?.toDouble() ?? 0.0;
    final double carbsVal = (macros?['carbs'] ?? map['carbs'] as num?)?.toDouble() ?? 0.0;
    final double fatVal = (macros?['fat'] ?? map['fat'] as num?)?.toDouble() ?? 0.0;
    final double fiberVal = (macros?['fiber'] ?? map['fiber'] as num?)?.toDouble() ?? 0.0;
    final double sugarVal = (macros?['sugar'] ?? map['sugar'] as num?)?.toDouble() ?? 0.0;
    final double sodiumVal = (macros?['sodium'] ?? map['sodium'] as num?)?.toDouble() ?? 0.0;

    final rawServings = map['servings'] as List<dynamic>?;
    List<ServingMeasure> servingsList = [];
    if (rawServings != null) {
      servingsList = rawServings
          .map((e) => ServingMeasure.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      // Create a default serving from servingSize
      servingsList = [
        ServingMeasure(
          name: map['servingSize'] ?? '100g',
          grams: 100.0,
          multiplier: 1.0,
        )
      ];
    }

    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      servingSize: map['servingSize'] ?? '100g',
      calories: caloriesVal,
      protein: proteinVal,
      carbs: carbsVal,
      fat: fatVal,
      fiber: fiberVal,
      sugar: sugarVal,
      sodium: sodiumVal,
      micronutrients: Map<String, double>.from(
        (map['micronutrients'] as Map<dynamic, dynamic>?)?.map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ) ?? {},
      ),
      imageUrl: map['imageUrl'] ?? '',
      lastUpdated: map['lastUpdated'] ?? '',
      servings: servingsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'servingSize': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'micronutrients': micronutrients,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated,
      'servings': servings.map((e) => e.toMap()).toList(),
      'macros': {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
      }
    };
  }
}

class MealEntry {
  final String id;
  final String userId;
  final String foodId;
  final String foodName;
  final String mealType;
  final double quantity;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final String imageUrl;
  final String photoUrl;
  final String timestamp;

  MealEntry({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.foodName,
    required this.mealType,
    required this.quantity,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.imageUrl = '',
    this.photoUrl = '',
    required this.timestamp,
  });

  factory MealEntry.fromMap(Map<String, dynamic> map, {String? id}) {
    return MealEntry(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      foodId: map['foodId'] ?? '',
      foodName: map['foodName'] ?? '',
      mealType: map['mealType'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      servingUnit: map['servingUnit'] ?? 'serving',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'foodId': foodId,
      'foodName': foodName,
      'mealType': mealType,
      'quantity': quantity,
      'servingUnit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'imageUrl': imageUrl,
      'photoUrl': photoUrl,
      'timestamp': timestamp,
    };
  }
}

class RecipeIngredient {
  final String foodId;
  final String foodName;
  final double quantity;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  RecipeIngredient({
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      foodId: map['foodId'] ?? '',
      foodName: map['foodName'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      servingUnit: map['servingUnit'] ?? 'serving',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'servingUnit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

class Recipe {
  final String id;
  final String userId;
  final String name;
  final String imageUrl;
  final int servingCount;
  final String prepNotes;
  final List<RecipeIngredient> ingredients;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final bool isTemplate;

  Recipe({
    required this.id,
    required this.userId,
    required this.name,
    this.imageUrl = '',
    this.servingCount = 1,
    this.prepNotes = '',
    required this.ingredients,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.isTemplate = false,
  });

  factory Recipe.fromMap(Map<String, dynamic> map, {String? id}) {
    return Recipe(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      servingCount: (map['servingCount'] as num?)?.toInt() ?? 1,
      prepNotes: map['prepNotes'] ?? '',
      ingredients: (map['ingredients'] as List<dynamic>? ?? [])
          .map((e) => RecipeIngredient.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalCalories: (map['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (map['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (map['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (map['totalFat'] as num?)?.toDouble() ?? 0.0,
      isTemplate: map['isTemplate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'imageUrl': imageUrl,
      'servingCount': servingCount,
      'prepNotes': prepNotes,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'isTemplate': isTemplate,
    };
  }
}

class WaterLog {
  final String id;
  final String userId;
  final String date;
  final int amountMl;

  WaterLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.amountMl,
  });

  factory WaterLog.fromMap(Map<String, dynamic> map, {String? id}) {
    return WaterLog(
      id: id ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      amountMl: (map['amountMl'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'amountMl': amountMl,
    };
  }
}
