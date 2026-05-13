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
        .orderBy('createdAt', descending: true)
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

  Future<void> saveMealPlan(StoredPlan plan) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('mealPlans').add(plan.toMap());
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
}
