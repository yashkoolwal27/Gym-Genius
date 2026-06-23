class Exercise {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final String equipmentType;
  final String difficulty;
  final List<String> categories;
  final List<String> goalTags;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String thumbnail;
  final String gifUrl;
  final List<String> steps;
  final List<String> alternatives;
  final bool isCompound;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.equipmentType,
    required this.difficulty,
    required this.categories,
    required this.goalTags,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.thumbnail,
    required this.gifUrl,
    required this.steps,
    required this.alternatives,
    required this.isCompound,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      exerciseId: map['exerciseId'] ?? '',
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      equipmentType: map['equipmentType'] ?? '',
      difficulty: map['difficulty'] ?? 'Beginner',
      categories: List<String>.from(map['categories'] ?? []),
      goalTags: List<String>.from(map['goalTags'] ?? []),
      primaryMuscles: List<String>.from(map['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(map['secondaryMuscles'] ?? []),
      thumbnail: map['thumbnail'] ?? '',
      gifUrl: map['gifUrl'] ?? '',
      steps: List<String>.from(map['steps'] ?? []),
      alternatives: List<String>.from(map['alternatives'] ?? []),
      isCompound: map['isCompound'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'muscleGroup': muscleGroup,
      'equipmentType': equipmentType,
      'difficulty': difficulty,
      'categories': categories,
      'goalTags': goalTags,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'thumbnail': thumbnail,
      'gifUrl': gifUrl,
      'steps': steps,
      'alternatives': alternatives,
      'isCompound': isCompound,
    };
  }
}
