class ExerciseFilterTags {
  static const Map<String, List<String>> regionsByMuscleGroup = {
    'Chest': ['Upper Chest', 'Middle Chest', 'Lower Chest', 'Inner Chest'],
    'Back': ['Lats', 'Upper Back', 'Mid Back', 'Lower Back'],
    'Shoulders': ['Front Delts', 'Side Delts', 'Rear Delts'],
    'Biceps': ['Long Head', 'Short Head', 'Brachialis'],
    'Triceps': ['Long Head', 'Lateral Head', 'Medial Head'],
    'Legs': ['Quads', 'Hamstrings', 'Glutes', 'Calves', 'Adductors', 'Abductors', 'Hip Flexors'],
    'Core': ['Upper Abs', 'Lower Abs', 'Obliques', 'Transverse Abdominis'],
    'Forearms': ['Flexors', 'Extensors'],
    'Cardio': ['Full Body'],
  };

  static const List<String> standardEquipment = [
    'Barbell',
    'Dumbbell',
    'Machine',
    'Bodyweight',
    'Cable',
    'Kettlebell',
    'Band',
  ];

  static const List<String> standardDifficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  static List<String> getFiltersForMuscleGroup(String muscleGroup) {
    final regions = regionsByMuscleGroup[muscleGroup] ?? [];
    return [
      'All',
      'Favorites',
      ...regions,
      ...standardEquipment,
      ...standardDifficulties,
    ];
  }
}
