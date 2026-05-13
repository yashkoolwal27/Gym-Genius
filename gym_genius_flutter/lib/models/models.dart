import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSet {
  final String id;
  String reps;
  String weight;

  WorkoutSet({required this.id, required this.reps, required this.weight});

  factory WorkoutSet.fromMap(Map<String, dynamic> map) => WorkoutSet(
        id: map['id'] ?? '',
        reps: map['reps'] ?? '',
        weight: map['weight'] ?? '',
      );

  Map<String, dynamic> toMap() => {'id': id, 'reps': reps, 'weight': weight};
}

class LoggedExercise {
  final String id;
  final String name;
  final List<WorkoutSet> sets;

  LoggedExercise({required this.id, required this.name, required this.sets});

  factory LoggedExercise.fromMap(Map<String, dynamic> map) => LoggedExercise(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        sets: (map['sets'] as List<dynamic>? ?? [])
            .map((s) => WorkoutSet.fromMap(s as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'sets': sets.map((s) => s.toMap()).toList(),
      };
}

class WorkoutLog {
  final String id;
  final String date;
  final String time;
  final List<String> exerciseTypes;
  final List<LoggedExercise> exercises;
  final String createdAt;

  WorkoutLog({
    required this.id,
    required this.date,
    required this.time,
    required this.exerciseTypes,
    required this.exercises,
    required this.createdAt,
  });

  factory WorkoutLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutLog(
      id: doc.id,
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      exerciseTypes: List<String>.from(data['exerciseTypes'] ?? []),
      exercises: (data['exercises'] as List<dynamic>? ?? [])
          .map((e) => LoggedExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: data['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'time': time,
        'exerciseTypes': exerciseTypes,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'createdAt': createdAt,
      };
}

class MealLog {
  final String id;
  final String createdAt;
  final String date;
  final String mealType;
  final String macronutrients;
  final String fitnessGoals;
  final String foodCategory;
  final String mealDetails;

  MealLog({
    required this.id,
    required this.createdAt,
    required this.date,
    required this.mealType,
    required this.macronutrients,
    required this.fitnessGoals,
    required this.foodCategory,
    required this.mealDetails,
  });

  factory MealLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealLog(
      id: doc.id,
      createdAt: data['createdAt'] ?? '',
      date: data['date'] ?? '',
      mealType: data['mealType'] ?? '',
      macronutrients: data['macronutrients'] ?? '',
      fitnessGoals: data['fitnessGoals'] ?? '',
      foodCategory: data['foodCategory'] ?? '',
      mealDetails: data['mealDetails'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt,
        'date': date,
        'mealType': mealType,
        'macronutrients': macronutrients,
        'fitnessGoals': fitnessGoals,
        'foodCategory': foodCategory,
        'mealDetails': mealDetails,
      };
}

class WeightLog {
  final String id;
  final String date;
  final double weight;

  WeightLog({required this.id, required this.date, required this.weight});

  factory WeightLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeightLog(
      id: doc.id,
      date: data['date'] ?? '',
      weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'date': date, 'weight': weight};
}

class StoredPlan {
  final String id;
  final String generatedPlan;
  final String createdAt;

  StoredPlan({required this.id, required this.generatedPlan, required this.createdAt});

  factory StoredPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoredPlan(
      id: doc.id,
      generatedPlan: data['generatedPlan'] ?? '',
      createdAt: data['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'generatedPlan': generatedPlan,
        'createdAt': createdAt,
      };
}

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int age;
  final double height; // cm
  final double weight; // kg
  final String fitnessGoal;
  final String activityLevel;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.age = 25,
    this.height = 170,
    this.weight = 70,
    this.fitnessGoal = 'Weight Loss',
    this.activityLevel = 'Moderate',
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: (data['age'] as num?)?.toInt() ?? 25,
      height: (data['height'] as num?)?.toDouble() ?? 170,
      weight: (data['weight'] as num?)?.toDouble() ?? 70,
      fitnessGoal: data['fitnessGoal'] ?? 'Weight Loss',
      activityLevel: data['activityLevel'] ?? 'Moderate',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'age': age,
        'height': height,
        'weight': weight,
        'fitnessGoal': fitnessGoal,
        'activityLevel': activityLevel,
      };
}
