import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/models.dart';
import '../core/exercises_data/exercises_data.dart';


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

  Future<String> uploadFoodImage(String foodId, File file) async {
    final storageRef = FirebaseStorage.instance.ref().child('food_images/$foodId.jpg');
    // Always overwrite by uploading to the same ref path
    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  // ───────── COMMUNITY FOOD MODERATION & LOGGING ─────────
  Future<void> submitFoodForReview(FoodItem food) async {
    if (_uid == null) return;
    final docRef = _db.collection('pending_food_reviews').doc(food.id);
    await docRef.set({
      'submittedBy': _uid,
      'submittedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'food': food.toMap(),
    });
  }

  Stream<List<Map<String, dynamic>>> getPendingReviewsStream() {
    return _db
        .collection('pending_food_reviews')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['reviewId'] = d.id;
              return data;
            }).toList());
  }

  Future<void> approveFoodReview(String reviewId, FoodItem food) async {
    if (_uid == null) return;
    
    // 1. Update review status
    await _db.collection('pending_food_reviews').doc(reviewId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': _uid,
    });

    // 2. Generate search keywords for foods_master
    final List<String> keywords = _generateKeywords(food.name);

    final foodMap = food.toMap();
    foodMap['searchKeywords'] = keywords;

    // 3. Write to foods_master
    await _db.collection('foods_master').doc(food.id).set(foodMap);

    // 4. Write to admin_foods (to show in Admin Portal local database list)
    await _db.collection('admin_foods').doc(food.id).set(foodMap);

    // 5. Log the override/approval action
    await logAdminAction(food.id, 'food_approve', {
      'reviewId': reviewId,
      'approvedName': food.name,
      'calories': food.calories,
    });
  }

  Future<void> rejectFoodReview(String reviewId, String reason) async {
    if (_uid == null) return;
    await _db.collection('pending_food_reviews').doc(reviewId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectedBy': _uid,
      'rejectionReason': reason,
    });

    await logAdminAction(reviewId, 'food_reject', {
      'reason': reason,
    });
  }

  Future<void> addAdminCreatedFood(FoodItem food) async {
    if (_uid == null) return;

    final keywords = _generateKeywords(food.name);
    final foodMap = food.toMap();
    foodMap['searchKeywords'] = keywords;

    await _db.collection('foods_master').doc(food.id).set(foodMap);
    await _db.collection('admin_foods').doc(food.id).set(foodMap);

    await logAdminAction(food.id, 'food_create', {
      'name': food.name,
      'calories': food.calories,
    });
  }

  Future<void> editAdminFood(FoodItem food) async {
    if (_uid == null) return;
    
    final keywords = _generateKeywords(food.name);
    final foodMap = food.toMap();
    foodMap['searchKeywords'] = keywords;

    await _db.collection('foods_master').doc(food.id).set(foodMap);
    await _db.collection('admin_foods').doc(food.id).set(foodMap);

    await logAdminAction(food.id, 'food_edit', {
      'name': food.name,
      'calories': food.calories,
    });
  }

  Future<void> deleteAdminFood(String foodId) async {
    if (_uid == null) return;
    await _db.collection('foods_master').doc(foodId).delete();
    await _db.collection('admin_foods').doc(foodId).delete();
    await logAdminAction(foodId, 'food_delete', {});
  }

  Stream<List<FoodItem>> getAdminFoodsStream() {
    return _db
        .collection('admin_foods')
        .snapshots()
        .map((snap) => snap.docs.map((d) => FoodItem.fromMap(d.data())).toList());
  }

  Stream<List<Map<String, dynamic>>> getAdminLogsStream() {
    return _db
        .collection('food_override_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['logId'] = d.id;
              return data;
            }).toList());
  }

  Future<void> logAdminAction(String foodId, String action, Map<String, dynamic> details) async {
    if (_uid == null) return;
    await _db.collection('food_override_logs').add({
      'foodId': foodId,
      'action': action,
      'actorId': _uid,
      'timestamp': FieldValue.serverTimestamp(),
      'details': details,
    });
  }

  List<String> _generateKeywords(String name) {
    final parts = name.toLowerCase().split(RegExp(r'\s+'));
    final Set<String> keywords = {};
    for (final part in parts) {
      if (part.isEmpty) continue;
      for (int i = 1; i <= part.length; i++) {
        keywords.add(part.substring(0, i));
      }
    }
    keywords.addAll(parts);
    return keywords.toList();
  }

  Future<bool> checkIfAdmin() async {
    if (_uid == null) return false;
    try {
      final email = _auth.currentUser?.email?.toLowerCase();
      final isYashKoolwal = email != null && email.contains('yashkoolwal');

      final doc = await _db.collection('users').doc(_uid).get();
      if (!doc.exists) {
        if (isYashKoolwal) {
          await _db.collection('users').doc(_uid).set({
            'email': email,
            'isAdmin': true,
            'basicProfile': {
              'isAdmin': true,
            },
          }, SetOptions(merge: true));
          return true;
        }
        return false;
      }
      
      final data = doc.data()!;
      var isAdminValue = data['isAdmin'] == true || 
          (data['basicProfile'] as Map<dynamic, dynamic>?)?['isAdmin'] == true;

      if (isYashKoolwal && !isAdminValue) {
        await _db.collection('users').doc(_uid).set({
          'isAdmin': true,
          'basicProfile': {
            'isAdmin': true,
          },
        }, SetOptions(merge: true));
        isAdminValue = true;
      }
      return isAdminValue;
    } catch (_) {
      return false;
    }
  }

  // ───────── EXERCISE DATABASE & PRs ─────────
  Future<List<Exercise>> getExercises() async {
    try {
      final snap = await _db.collection('exercise_master').get();
      bool needsReSeed = false;
      if (snap.docs.isNotEmpty) {
        final firstDoc = snap.docs.first.data();
        if (!firstDoc.containsKey('targetRegions') || snap.docs.length != ExercisesData.masterExercises.length) {
          needsReSeed = true;
        }
      }
      if (snap.docs.isEmpty || needsReSeed) {
        // Seed/overwrite from local in batches of 400 (Firestore max is 500 per batch)
        final localList = ExercisesData.masterExercises;
        for (int i = 0; i < localList.length; i += 400) {
          final batch = _db.batch();
          final end = (i + 400 < localList.length) ? i + 400 : localList.length;
          for (int j = i; j < end; j++) {
            final ex = localList[j];
            final docRef = _db.collection('exercise_master').doc(ex.exerciseId);
            batch.set(docRef, ex.toMap());
          }
          await batch.commit();
        }
        return localList;
      } else {
        return snap.docs.map((d) => Exercise.fromMap(d.data())).toList();
      }
    } catch (e) {
      // Fallback to local
      return ExercisesData.masterExercises;
    }
  }

  Future<Map<String, double>> getPersonalRecords() async {
    if (_uid == null) return {};
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('personal_records')
          .get();
      final Map<String, double> records = {};
      for (final doc in snap.docs) {
        final val = doc.data()['weight'];
        if (val != null) {
          records[doc.id] = (val as num).toDouble();
        }
      }
      return records;
    } catch (_) {
      return {};
    }
  }

  Future<void> updatePersonalRecord(String exerciseId, double weight) async {
    if (_uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('personal_records')
          .doc(exerciseId)
          .set({
        'weight': weight,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ───────── FAVORITE EXERCISES ─────────
  Future<void> toggleFavoriteExercise(String exerciseId, bool isFavorite) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('favorite_exercises')
        .doc(exerciseId);

    if (isFavorite) {
      await docRef.set({
        'exerciseId': exerciseId,
        'isFavorite': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }

  Future<List<String>> getFavoriteExercises() async {
    if (_uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('favorite_exercises')
          .get();
      return snap.docs.map((d) => d.id).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<String>> getFavoriteExercisesStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('favorite_exercises')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  // ───────── WORKOUT TEMPLATES ─────────
  Future<void> saveWorkoutTemplate(WorkoutTemplate template) async {
    if (_uid == null) return;
    final collection = _db
        .collection('users')
        .doc(_uid)
        .collection('workout_templates');
    
    if (template.id.isEmpty) {
      await collection.add(template.toMap());
    } else {
      await collection.doc(template.id).set(template.toMap(), SetOptions(merge: true));
    }
  }

  Future<List<WorkoutTemplate>> getWorkoutTemplates() async {
    if (_uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('workout_templates')
          .get();
      return snap.docs.map((d) => WorkoutTemplate.fromMap(d.data(), d.id)).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<WorkoutTemplate>> getWorkoutTemplatesStream() {
    if (_uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('workout_templates')
        .snapshots()
        .map((snap) => snap.docs.map((d) => WorkoutTemplate.fromMap(d.data(), d.id)).toList());
  }

  Future<void> deleteWorkoutTemplate(String templateId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('workout_templates')
        .doc(templateId)
        .delete();
  }
}



