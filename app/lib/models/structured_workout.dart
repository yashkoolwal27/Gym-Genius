class StructuredWorkoutPlan {
  final String title;
  final List<WorkoutExercise> exercises;

  StructuredWorkoutPlan({
    required this.title,
    required this.exercises,
  });

  factory StructuredWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return StructuredWorkoutPlan(
      title: json['title'] ?? 'Workout Plan',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutExercise {
  final String category;
  final String name;
  final int sets;
  final String reps;
  final String weightRecommendation;
  final int restBetweenSetsSeconds;
  final int restAfterExerciseSeconds;
  final String tipsOrGoal;

  WorkoutExercise({
    required this.category,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weightRecommendation,
    required this.restBetweenSetsSeconds,
    required this.restAfterExerciseSeconds,
    required this.tipsOrGoal,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      category: json['category'] ?? '',
      name: json['exerciseName'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps']?.toString() ?? '',
      weightRecommendation: json['weightRecommendation'] ?? '',
      restBetweenSetsSeconds: json['restBetweenSets'] ?? 60,
      restAfterExerciseSeconds: json['restAfterExercise'] ?? 120,
      tipsOrGoal: json['tipsOrGoal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'exerciseName': name,
      'sets': sets,
      'reps': reps,
      'weightRecommendation': weightRecommendation,
      'restBetweenSets': restBetweenSetsSeconds,
      'restAfterExercise': restAfterExerciseSeconds,
      'tipsOrGoal': tipsOrGoal,
    };
  }
}
