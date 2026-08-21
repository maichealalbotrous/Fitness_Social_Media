import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_repository.dart';

class UserSessionController extends ChangeNotifier {
  UserSessionController(this.repository);
  final UserSessionRepository repository;
  List<UserSession> sessions = const [];
  bool isLoading = false;
  String? error;
  String? message;

  Future<void> loadAll() async => _run(() async { sessions = await repository.getAll(); });
  Future<void> loadByDay(DateTime date) async => _run(() async { sessions = await repository.getByDay(date); });
  Future<void> loadByMonth(int year, int month) async => _run(() async { sessions = await repository.getByMonth(year, month); });
  Future<void> create({required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises}) async => _run(() async { final created = await repository.create(description: description, muscles: muscles, totalDurationMinutes: totalDurationMinutes, exercises: exercises); sessions = [created, ...sessions]; message = 'Training session created.'; });
  Future<void> update({required String id, required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises}) async => _run(() async { final updated = await repository.update(id: id, description: description, muscles: muscles, totalDurationMinutes: totalDurationMinutes, exercises: exercises); sessions = sessions.map((item) => item.id == updated.id ? updated : item).toList(growable: false); message = 'Training session updated.'; });

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();
    try { await action(); } on ApiException catch (exception) { error = exception.message; } catch (_) { error = 'Unable to complete the training session operation.'; } finally { isLoading = false; notifyListeners(); }
  }
}
