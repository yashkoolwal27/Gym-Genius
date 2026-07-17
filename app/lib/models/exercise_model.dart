class Exercise {
  final String exerciseId;
  final String name;
  final List<String> aliases;
  final String muscleGroup;
  final List<String> targetRegions;
  final String exerciseType;
  final List<String> trainingStyles;
  final List<String> categories;
  final List<String> equipment;
  final String difficulty;
  final String movementPattern;
  final List<String> goalTags;
  final bool isCompound;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String mechanics;
  final String forceType;
  final String bodyRegion;
  final List<String> environment;
  final List<String> injuryFriendly;
  final List<String> alternatives;
  final List<String> progressions;
  final List<String> regressions;
  final String thumbnail;
  final String gifUrl;
  final String videoUrl;
  final List<String> steps;
  final List<String> commonMistakes;
  final List<String> safetyTips;
  final String breathing;
  final double estimatedCaloriesPerMinute;
  final List<String> tags;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.aliases,
    required this.muscleGroup,
    required this.targetRegions,
    required this.exerciseType,
    required this.trainingStyles,
    required this.categories,
    required this.equipment,
    required this.difficulty,
    required this.movementPattern,
    required this.goalTags,
    required this.isCompound,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.mechanics,
    required this.forceType,
    required this.bodyRegion,
    required this.environment,
    required this.injuryFriendly,
    required this.alternatives,
    required this.progressions,
    required this.regressions,
    required this.thumbnail,
    required this.gifUrl,
    required this.videoUrl,
    required this.steps,
    required this.commonMistakes,
    required this.safetyTips,
    required this.breathing,
    required this.estimatedCaloriesPerMinute,
    required this.tags,
  });

  // Backward compatibility getters
  String get equipmentType => equipment.isNotEmpty ? equipment.first : '';

  factory Exercise.fromMap(Map<String, dynamic> map) {
    final parsedTargetRegions = map['targetRegions'] != null
        ? List<String>.from(map['targetRegions'])
        : (map['subMuscleGroup'] != null && (map['subMuscleGroup'] as String).isNotEmpty
            ? [map['subMuscleGroup'] as String]
            : <String>[]);

    final parsedCategories = map['categories'] != null
        ? List<String>.from(map['categories'])
        : List<String>.from(map['trainingStyles'] ?? []);

    final parsedTags = map['tags'] != null
        ? List<String>.from(map['tags'])
        : <String>[
            ...parsedTargetRegions,
            ...List<String>.from(map['equipment'] ?? []),
            map['difficulty'] ?? 'Beginner',
            map['isCompound'] == true ? 'Compound' : 'Isolation',
            map['exerciseType'] ?? '',
            map['movementPattern'] ?? '',
            map['bodyRegion'] ?? '',
          ].where((t) => t.isNotEmpty).toList();

    return Exercise(
      exerciseId: map['exerciseId'] ?? '',
      name: map['name'] ?? '',
      aliases: List<String>.from(map['aliases'] ?? []),
      muscleGroup: map['muscleGroup'] ?? '',
      targetRegions: parsedTargetRegions,
      exerciseType: map['exerciseType'] ?? '',
      trainingStyles: List<String>.from(map['trainingStyles'] ?? []),
      categories: parsedCategories,
      equipment: List<String>.from(map['equipment'] ?? []),
      difficulty: map['difficulty'] ?? 'Beginner',
      movementPattern: map['movementPattern'] ?? '',
      goalTags: List<String>.from(map['goalTags'] ?? []),
      isCompound: map['isCompound'] ?? false,
      primaryMuscles: List<String>.from(map['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(map['secondaryMuscles'] ?? []),
      mechanics: map['mechanics'] ?? '',
      forceType: map['forceType'] ?? '',
      bodyRegion: map['bodyRegion'] ?? '',
      environment: List<String>.from(map['environment'] ?? []),
      injuryFriendly: map['injuryFriendly'] is List
          ? List<String>.from(map['injuryFriendly'])
          : [],
      alternatives: List<String>.from(map['alternatives'] ?? []),
      progressions: List<String>.from(map['progressions'] ?? []),
      regressions: List<String>.from(map['regressions'] ?? []),
      thumbnail: map['thumbnail'] ?? '',
      gifUrl: map['gifUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      steps: List<String>.from(map['steps'] ?? []),
      commonMistakes: List<String>.from(map['commonMistakes'] ?? []),
      safetyTips: List<String>.from(map['safetyTips'] ?? []),
      breathing: map['breathing'] ?? '',
      estimatedCaloriesPerMinute: (map['estimatedCaloriesPerMinute'] as num?)?.toDouble() ?? 0.0,
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'aliases': aliases,
      'muscleGroup': muscleGroup,
      'targetRegions': targetRegions,
      'exerciseType': exerciseType,
      'trainingStyles': trainingStyles,
      'categories': categories,
      'equipment': equipment,
      'difficulty': difficulty,
      'movementPattern': movementPattern,
      'goalTags': goalTags,
      'isCompound': isCompound,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'mechanics': mechanics,
      'forceType': forceType,
      'bodyRegion': bodyRegion,
      'environment': environment,
      'injuryFriendly': injuryFriendly,
      'alternatives': alternatives,
      'progressions': progressions,
      'regressions': regressions,
      'thumbnail': thumbnail,
      'gifUrl': gifUrl,
      'videoUrl': videoUrl,
      'steps': steps,
      'commonMistakes': commonMistakes,
      'safetyTips': safetyTips,
      'breathing': breathing,
      'estimatedCaloriesPerMinute': estimatedCaloriesPerMinute,
      'tags': tags,
    };
  }
}
