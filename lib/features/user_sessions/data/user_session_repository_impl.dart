import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/user_sessions/data/user_session_remote_data_source.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_repository.dart';

class UserSessionRepositoryImpl implements UserSessionRepository {
  const UserSessionRepositoryImpl(this.remote);
  final UserSessionRemoteDataSource remote;

  @override Future<List<UserSession>> getAll() => remote.getAll();
  @override Future<List<UserSession>> getByDay(DateTime date) => remote.getByDay(date);
  @override Future<List<UserSession>> getByMonth(int year, int month) => remote.getByMonth(year, month);
  @override Future<UserSession> create({required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises}) => remote.create(description: description, muscles: muscles, totalDurationMinutes: totalDurationMinutes, exercises: exercises);
  @override Future<UserSession> update({required String id, required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises}) => remote.update(id: id, description: description, muscles: muscles, totalDurationMinutes: totalDurationMinutes, exercises: exercises);
}
