import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';

abstract interface class UserSessionRepository {
  Future<List<UserSession>> getAll();
  Future<List<UserSession>> getByDay(DateTime date);
  Future<List<UserSession>> getByMonth(int year, int month);
  Future<UserSession> create({required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises});
  Future<UserSession> update({required String id, required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises});
}
