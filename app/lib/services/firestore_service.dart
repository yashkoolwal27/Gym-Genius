import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ───────── USER PROFILE ─────────
  Future<void> saveUserProfile(UserProfile profile) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile() async {
    if (_uid == null) return null;
    final doc = await _db.collection('users').doc(_uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  // ───────── WORKOUT LOGS ─────────
  Future<void> addWorkoutLog(WorkoutLog log) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('workoutLogs').add(log.toMap());
  }

  Stream<List<WorkoutLog>> getWorkoutLogsStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('workoutLogs')
        .snapshots()
        .map((snap) => snap.docs.map((d) => WorkoutLog.fromFirestore(d)).toList());
  }

  Future<List<WorkoutLog>> getWorkoutLogs() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('workoutLogs')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => WorkoutLog.fromFirestore(d)).toList();
  }

  Future<void> deleteWorkoutLog(String logId) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('workoutLogs').doc(logId).delete();
  }

  // ───────── MEAL LOGS ─────────
  Future<void> addMealLog(MealLog log) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('mealLogs').add(log.toMap());
  }

  Stream<List<MealLog>> getMealLogsStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('mealLogs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MealLog.fromFirestore(d)).toList());
  }

  Future<List<MealLog>> getMealLogs() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('mealLogs')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => MealLog.fromFirestore(d)).toList();
  }

  Future<void> deleteMealLog(String logId) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('mealLogs').doc(logId).delete();
  }

  // ───────── WEIGHT LOGS ─────────
  Future<void> addWeightLog(WeightLog log) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('weightLogs').add(log.toMap());
  }

  Stream<List<WeightLog>> getWeightLogsStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('weightLogs')
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs.map((d) => WeightLog.fromFirestore(d)).toList());
  }

  Future<List<WeightLog>> getWeightLogs() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('weightLogs')
        .orderBy('date')
        .get();
    return snap.docs.map((d) => WeightLog.fromFirestore(d)).toList();
  }

  // ───────── STORED PLANS ─────────
  Future<void> saveWorkoutPlan(StoredPlan plan) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('workoutPlans').add(plan.toMap());
  }

  Future<List<StoredPlan>> getWorkoutPlans() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('workoutPlans')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => StoredPlan.fromFirestore(d)).toList();
  }

  Future<List<StoredPlan>> getMealPlans() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('mealPlans')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => StoredPlan.fromFirestore(d)).toList();
  }

  // ───────── NUTRITION MEAL ENTRIES ─────────
  Future<void> addMealEntry(MealEntry entry) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('meal_entries')
        .doc(entry.id)
        .set(entry.toMap());
  }

  Stream<List<MealEntry>> getMealEntriesStream(String date) {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('meal_entries')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MealEntry.fromMap(d.data(), id: d.id))
            .where((element) => element.timestamp.startsWith(date))
            .toList());
  }

  Future<List<MealEntry>> getMealEntriesForDate(String date) async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('meal_entries')
        .get();
    return snap.docs
        .map((d) => MealEntry.fromMap(d.data(), id: d.id))
        .where((element) => element.timestamp.startsWith(date))
        .toList();
  }

  Future<void> deleteMealEntry(String entryId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('meal_entries')
        .doc(entryId)
        .delete();
  }

  // ───────── RECIPES ─────────
  Future<void> addRecipe(Recipe recipe) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('recipes')
        .doc(recipe.id)
        .set(recipe.toMap());
  }

  Stream<List<Recipe>> getRecipesStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('recipes')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Recipe.fromMap(d.data(), id: d.id)).toList());
  }

  Future<void> deleteRecipe(String recipeId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('recipes')
        .doc(recipeId)
        .delete();
  }

  // ───────── WATER LOGS ─────────
  Future<void> logWater(String date, int amountMl) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('water_logs')
        .doc(date);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'id': date,
          'userId': _uid,
          'date': date,
          'amountMl': amountMl,
        });
      } else {
        final currentAmount = (snapshot.data()?['amountMl'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {'amountMl': currentAmount + amountMl});
      }
    });
  }

  Stream<int> getWaterLogStream(String date) {
    if (_uid == null) return Stream.value(0);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('water_logs')
        .doc(date)
        .snapshots()
        .map((snap) => (snap.data()?['amountMl'] as num?)?.toInt() ?? 0);
  }

  Future<int> getWaterLog(String date) async {
    if (_uid == null) return 0;
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('water_logs')
        .doc(date)
        .get();
    return (snap.data()?['amountMl'] as num?)?.toInt() ?? 0;
  }

  // ───────── FAVORITE FOODS ─────────
  Future<void> toggleFavoriteFood(FoodItem food) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('favorite_foods')
        .doc(food.id);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set(food.toMap());
    }
  }

  Stream<List<FoodItem>> getFavoriteFoodsStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('favorite_foods')
        .snapshots()
        .map((snap) => snap.docs.map((d) => FoodItem.fromMap(d.data())).toList());
  }

  Future<bool> isFoodFavorite(String foodId) async {
    if (_uid == null) return false;
    final doc = await _db
        .collection('users')
        .doc(_uid)
        .collection('favorite_foods')
        .doc(foodId)
        .get();
    return doc.exists;
  }

  // ───────── NUTRITION GOALS OVERRIDE ─────────
  Future<void> saveNutritionGoals(Map<String, double> goals) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('nutrition_goals')
        .doc('current')
        .set(goals);
  }

  Future<Map<String, double>?> getNutritionGoals() async {
    if (_uid == null) return null;
    final doc = await _db
        .collection('users')
        .doc(_uid)
        .collection('nutrition_goals')
        .doc('current')
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return doc.data()!.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  // ───────── STREAKS ─────────
  Future<Map<String, dynamic>> updateAndGetStreak() async {
    if (_uid == null) return {'streak': 0, 'lastLogged': ''};
    final userDoc = _db.collection('users').doc(_uid);
    
    return await _db.runTransaction((transaction) async {
      final snap = await transaction.get(userDoc);
      if (!snap.exists) return {'streak': 0, 'lastLogged': ''};
      
      final data = snap.data() ?? {};
      int streak = (data['streakCount'] as num?)?.toInt() ?? 0;
      String lastLogged = data['lastLoggedDate'] ?? '';
      
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final yesterdayStr = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
      
      if (lastLogged != todayStr) {
        if (lastLogged == yesterdayStr) {
          streak += 1;
        } else {
          streak = 1;
        }
        transaction.update(userDoc, {
          'streakCount': streak,
          'lastLoggedDate': todayStr,
        });
        lastLogged = todayStr;
      }
      
      return {'streak': streak, 'lastLogged': lastLogged};
    });
  }

  // ───────── CUSTOM FOODS ─────────
  Future<void> addCustomFood(FoodItem food) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('custom_foods')
        .doc(food.id)
        .set(food.toMap());
  }

  Future<List<FoodItem>> getCustomFoods() async {
    if (_uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('custom_foods')
          .get();
      return snap.docs.map((d) => FoodItem.fromMap(d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  // ───────── GLOBAL FOOD OVERRIDES ─────────
  Future<void> updateGlobalFoodImage(String foodId, String newImageUrl) async {
    await _db
        .collection('global_food_overrides')
        .doc(foodId)
        .set({'imageUrl': newImageUrl}, SetOptions(merge: true));
  }

  Future<Map<String, String>> getGlobalFoodOverrides() async {
    try {
      final snap = await _db.collection('global_food_overrides').get();
      final Map<String, String> overrides = {};
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['imageUrl'] != null) {
          overrides[doc.id] = data['imageUrl'] as String;
        }
      }
      return overrides;
    } catch (_) {
      return {};
    }
  }

  Future<bool> checkIfAdmin() async {
    return true; // Temporary test override
  }
}


