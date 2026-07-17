import '../../models/models.dart';
import 'chest_exercises.dart';
import 'back_exercises.dart';
import 'shoulders_exercises.dart';
import 'biceps_exercises.dart';
import 'triceps_exercises.dart';
import 'forearms_exercises.dart';
import 'legs_exercises.dart';
import 'cardio_exercises.dart';
import 'abs_exercises.dart';

class ExercisesData {
  static final List<Exercise> masterExercises = [
    ...ChestExercises.exercises,
    ...BackExercises.exercises,
    ...ShouldersExercises.exercises,
    ...BicepsExercises.exercises,
    ...TricepsExercises.exercises,
    ...ForearmsExercises.exercises,
    ...LegExercises.exercises,
    ...CardioExercises.exercises,
    ...AbsExercises.exercises,
  ];
}
