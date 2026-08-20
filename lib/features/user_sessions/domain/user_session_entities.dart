import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';

class UserExerciseRecord {
  const UserExerciseRecord({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseDescription,
    required this.mainMuscle,
    required this.secondaryMuscles,
    required this.reps,
    required this.sets,
    required this.weight,
    required this.isPr,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final String exerciseDescription;
  final ExerciseMuscle mainMuscle;
  final List<ExerciseMuscle> secondaryMuscles;
  final int reps;
  final int sets;
  final double weight;
  final bool isPr;
}

class UserSession {
  const UserSession({
    required this.id,
    required this.userId,
    this.description,
    required this.muscles,
    required this.date,
    required this.totalDuration,
    required this.exercises,
  });

  final String id;
  final String userId;
  final String? description;
  final List<ExerciseMuscle> muscles;
  final DateTime date;
  final String totalDuration;
  final List<UserExerciseRecord> exercises;
}

class UserExerciseInput {
  const UserExerciseInput({
    required this.exerciseId,
    required this.reps,
    required this.sets,
    required this.weight,
  });

  final String exerciseId;
  final int reps;
  final int sets;
  final double weight;

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'reps': reps,
    'sets': sets,
    'weight': weight,
  };
}
