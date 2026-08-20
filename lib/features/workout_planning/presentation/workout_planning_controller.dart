import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';
import 'package:fitness_social_app/features/workout_planning/domain/workout_planning_entities.dart';
import 'package:fitness_social_app/features/workout_planning/domain/workout_planning_repository.dart';

class WorkoutPlanningController extends ChangeNotifier {
  WorkoutPlanningController(this.repository);
  final WorkoutPlanningRepository repository;
  List<WorkoutTemplate> templates = const [];
  List<WorkoutPlan> plans = const [];
  bool isLoading = false;
  String? error;
  String? message;

  Future<void> loadTemplates() async => _run(() async { templates = await repository.getTemplates(); });
  Future<void> loadPlans() async => _run(() async { plans = await repository.getPlans(); });
  Future<void> createTemplate({required String name, required int durationDays, required bool isGeneral, required List<TemplateDayInput> days}) async => _run(() async { final item = await repository.createTemplate(name: name, durationDays: durationDays, isGeneral: isGeneral, days: days); templates = [item, ...templates]; message = 'Template created.'; });
  Future<void> archiveTemplate(String id) async => _run(() async { await repository.archiveTemplate(id); templates = templates.where((item) => item.id != id).toList(growable: false); message = 'Template archived.'; });
  Future<void> createPlan({required String name, required int durationDays, String? ownerUserId, required List<String> templateIds, required List<ManualPlanDayInput> days}) async => _run(() async { final item = await repository.createPlan(name: name, durationDays: durationDays, ownerUserId: ownerUserId, templateIds: templateIds, days: days); plans = [item, ...plans]; message = 'Plan created.'; });
  Future<void> sendPlan(String id) async => _action(() => repository.sendPlan(id), 'Plan sent.');
  Future<void> acceptPlan(String id) async => _action(() => repository.acceptPlan(id), 'Plan accepted.');
  Future<void> rejectPlan(String id) async => _action(() => repository.rejectPlan(id), 'Plan rejected.');
  Future<void> startPlan(String id, DateTime startDate) async => _run(() async { final updated = await repository.startPlan(id, startDate); _replace(updated); message = 'Plan started.'; });
  Future<void> completeDay({required String planId, required String dayId, required int totalDurationMinutes, required String? description, required List<ExerciseMuscle> muscles, required List<UserExerciseInput> exercises}) async => _run(() async { final updated = await repository.completeDay(planId: planId, dayId: dayId, totalDurationMinutes: totalDurationMinutes, description: description, muscles: muscles, exercises: exercises); _replace(updated); message = 'Workout day completed.'; });
  Future<void> _action(Future<void> Function() action, String success) async => _run(() async { await action(); message = success; await loadPlans(); });
  void _replace(WorkoutPlan updated) { plans = plans.map((item) => item.id == updated.id ? updated : item).toList(growable: false); }
  Future<void> _run(Future<void> Function() action) async { isLoading = true; error = null; message = null; notifyListeners(); try { await action(); } on ApiException catch (exception) { error = exception.message; } catch (_) { error = 'Unable to complete workout planning operation.'; } finally { isLoading = false; notifyListeners(); } }
}
