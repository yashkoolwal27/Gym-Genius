import 'package:cloud_firestore/cloud_firestore.dart';
export 'structured_workout.dart';
export 'nutrition_models.dart';



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
  final String email;
  final bool onboardingCompleted;

  // Nested structures
  final Map<String, dynamic> basicProfile;
  final Map<String, dynamic> goals;
  final Map<String, dynamic> personalInfo;
  final Map<String, dynamic> advancedMetrics;
  final Map<String, dynamic> healthInfo;
  final Map<String, dynamic> gymInfo;
  final Map<String, dynamic> aiPreferences;
  final Map<String, dynamic> connectedDevices;
  final Map<String, dynamic> notifications;
  final Map<String, dynamic> progressPhotos;

  UserProfile({
    required this.uid,
    required this.email,
    this.onboardingCompleted = true,
    Map<String, dynamic>? basicProfile,
    Map<String, dynamic>? goals,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? advancedMetrics,
    Map<String, dynamic>? healthInfo,
    Map<String, dynamic>? gymInfo,
    Map<String, dynamic>? aiPreferences,
    Map<String, dynamic>? connectedDevices,
    Map<String, dynamic>? notifications,
    Map<String, dynamic>? progressPhotos,
  })  : this.basicProfile = basicProfile ?? {},
        this.goals = goals ?? {},
        this.personalInfo = personalInfo ?? {},
        this.advancedMetrics = advancedMetrics ?? {},
        this.healthInfo = healthInfo ?? {},
        this.gymInfo = gymInfo ?? {},
        this.aiPreferences = aiPreferences ?? {},
        this.connectedDevices = connectedDevices ?? {},
        this.notifications = notifications ?? {},
        this.progressPhotos = progressPhotos ?? {};

  // Getters for backward compatibility
  String get name => basicProfile['name'] ?? '';
  int get age => (basicProfile['age'] as num?)?.toInt() ?? 25;
  double get height => (basicProfile['height'] as num?)?.toDouble() ?? 170.0;
  double get weight => (basicProfile['weight'] as num?)?.toDouble() ?? 70.0;
  String get fitnessGoal => basicProfile['goal'] ?? 'Weight Loss';
  String get activityLevel => basicProfile['activityLevel'] ?? 'Moderate';
  String get dietPreference => basicProfile['dietPreference'] ?? 'Vegetarian';

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      onboardingCompleted: data['onboardingCompleted'] ?? true,
      basicProfile: Map<String, dynamic>.from(data['basicProfile'] ?? {}),
      goals: Map<String, dynamic>.from(data['goals'] ?? {}),
      personalInfo: Map<String, dynamic>.from(data['personalInfo'] ?? {}),
      advancedMetrics: Map<String, dynamic>.from(data['advancedMetrics'] ?? {}),
      healthInfo: Map<String, dynamic>.from(data['healthInfo'] ?? {}),
      gymInfo: Map<String, dynamic>.from(data['gymInfo'] ?? {}),
      aiPreferences: Map<String, dynamic>.from(data['aiPreferences'] ?? {}),
      connectedDevices: Map<String, dynamic>.from(data['connectedDevices'] ?? {}),
      notifications: Map<String, dynamic>.from(data['notifications'] ?? {}),
      progressPhotos: Map<String, dynamic>.from(data['progressPhotos'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'onboardingCompleted': onboardingCompleted,
        'basicProfile': basicProfile,
        'goals': goals,
        'personalInfo': personalInfo,
        'advancedMetrics': advancedMetrics,
        'healthInfo': healthInfo,
        'gymInfo': gymInfo,
        'aiPreferences': aiPreferences,
        'connectedDevices': connectedDevices,
        'notifications': notifications,
        'progressPhotos': progressPhotos,
        'profileCompletion': getCompletionPercentage(),
      };

  // Profile completion calculation based on user requirements:
  // - Basic Profile (Stage 1 Complete): 40%
  // - Body Metrics (Advanced Body Metrics): +20%
  // - Health Data (Health Info): +15%
  // - Gym Data (Gym Info): +10%
  // - Photos (Progress Photos): +10%
  // - AI Preferences (Coaching Style): +5%
  int getCompletionPercentage() {
    double percentage = 0.0;

    // 1. Basic Profile (Stage 1 Complete): 40%
    // Verify required fields from Stage 1: name, gender, age, height, weight, goal, activityLevel, dietPreference
    final basicKeys = ['name', 'gender', 'age', 'height', 'weight', 'goal', 'activityLevel', 'dietPreference'];
    int basicFilled = 0;
    for (final key in basicKeys) {
      if (basicProfile[key] != null && basicProfile[key].toString().trim().isNotEmpty) {
        basicFilled++;
      }
    }
    if (basicKeys.isNotEmpty) {
      percentage += (basicFilled / basicKeys.length) * 40.0;
    }

    // 2. Body Metrics: 20%
    final metricKeys = ['bodyFat', 'muscleMass', 'chest', 'waist', 'shoulders', 'neck', 'forearms', 'biceps', 'hip', 'thighs', 'calves', 'boneMass', 'visceralFat'];
    int metricsFilled = 0;
    for (final key in metricKeys) {
      if (advancedMetrics[key] != null && advancedMetrics[key].toString().trim().isNotEmpty) {
        metricsFilled++;
      }
    }
    if (metricKeys.isNotEmpty) {
      percentage += (metricsFilled / metricKeys.length) * 20.0;
    }

    // 3. Health Data: 15%
    final healthKeys = ['bloodGroup', 'bloodPressure', 'restingHeartRate', 'sleepDuration', 'dailySteps', 'allergies', 'injuries', 'medicalNotes', 'healthConditions'];
    int healthFilled = 0;
    for (final key in healthKeys) {
      if (healthInfo[key] != null && healthInfo[key].toString().trim().isNotEmpty) {
        healthFilled++;
      }
    }
    if (healthKeys.isNotEmpty) {
      percentage += (healthFilled / healthKeys.length) * 15.0;
    }

    // 4. Gym Data: 10%
    final gymKeys = ['gymName', 'trainerName', 'workoutSplit', 'trainingExperience', 'equipmentAvailability', 'preferredWorkoutTime', 'workoutDaysPerWeek'];
    int gymFilled = 0;
    for (final key in gymKeys) {
      if (gymInfo[key] != null && gymInfo[key].toString().trim().isNotEmpty) {
        gymFilled++;
      }
    }
    if (gymKeys.isNotEmpty) {
      percentage += (gymFilled / gymKeys.length) * 10.0;
    }

    // 5. Photos: 10%
    final photoKeys = ['frontPhotoUrl', 'sidePhotoUrl', 'backPhotoUrl', 'monthlyProgressUrl'];
    int photosFilled = 0;
    for (final key in photoKeys) {
      if (progressPhotos[key] != null && progressPhotos[key].toString().trim().isNotEmpty) {
        photosFilled++;
      }
    }
    if (photoKeys.isNotEmpty) {
      percentage += (photosFilled / photoKeys.length) * 10.0;
    }

    // 6. AI Preferences: 5%
    if (aiPreferences['coachingStyle'] != null && aiPreferences['coachingStyle'].toString().trim().isNotEmpty) {
      percentage += 5.0;
    }

    return percentage.round().clamp(0, 100);
  }

  // Returns list of high-priority missing fields for the Health Check Card
  List<Map<String, String>> getMissingFields() {
    final List<Map<String, String>> missing = [];

    if (advancedMetrics['bodyFat'] == null || advancedMetrics['bodyFat'].toString().trim().isEmpty) {
      missing.add({'field': 'Body Fat %', 'section': 'Body Measurements'});
    }
    if (progressPhotos['frontPhotoUrl'] == null || progressPhotos['frontPhotoUrl'].toString().trim().isEmpty) {
      missing.add({'field': 'Progress Photos', 'section': 'Progress Photos'});
    }
    if (healthInfo['sleepDuration'] == null || healthInfo['sleepDuration'].toString().trim().isEmpty) {
      missing.add({'field': 'Sleep Duration', 'section': 'Health Information'});
    }
    if (gymInfo['workoutDaysPerWeek'] == null || gymInfo['workoutDaysPerWeek'].toString().trim().isEmpty) {
      missing.add({'field': 'Workout Days Per Week', 'section': 'Gym Information'});
    }
    if (aiPreferences['coachingStyle'] == null || aiPreferences['coachingStyle'].toString().trim().isEmpty) {
      missing.add({'field': 'Coaching Style', 'section': 'AI Personalization'});
    }

    return missing;
  }
}
