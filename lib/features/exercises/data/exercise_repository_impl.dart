import 'package:fitness_social_app/features/exercises/data/exercise_remote_data_source.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  const ExerciseRepositoryImpl(this.remote);
  final ExerciseRemoteDataSource remote;
  @override Future<List<Exercise>> getAll() => remote.getAll();
  @override Future<List<String>> getMuscles() => remote.getMuscles();
  @override Future<List<Exercise>> getByMainMuscle(ExerciseMuscle muscle) => remote.getByMainMuscle(muscle);
  @override Future<List<Exercise>> getBySecondaryMuscle(ExerciseMuscle muscle) => remote.getBySecondaryMuscle(muscle);
  @override Future<Exercise?> getById(String id) => remote.getById(id);
  @override Future<Exercise> create({required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles}) => remote.create(name: name, description: description, mainMuscle: mainMuscle, secondaryMuscles: secondaryMuscles);
  @override Future<Exercise> update({required String id, required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles}) => remote.update(id: id, name: name, description: description, mainMuscle: mainMuscle, secondaryMuscles: secondaryMuscles);
  @override Future<void> delete(String id) => remote.delete(id);
}
