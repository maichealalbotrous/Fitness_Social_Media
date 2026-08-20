import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';

abstract interface class ExerciseRepository {
  Future<List<Exercise>> getAll();
  Future<List<String>> getMuscles();
  Future<List<Exercise>> getByMainMuscle(ExerciseMuscle muscle);
  Future<List<Exercise>> getBySecondaryMuscle(ExerciseMuscle muscle);
  Future<Exercise?> getById(String id);
  Future<Exercise> create({required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles});
  Future<Exercise> update({required String id, required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles});
  Future<void> delete(String id);
}
