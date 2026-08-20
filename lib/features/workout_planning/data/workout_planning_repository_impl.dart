import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';
import 'package:fitness_social_app/features/workout_planning/data/workout_planning_remote_data_source.dart';
import 'package:fitness_social_app/features/workout_planning/domain/workout_planning_entities.dart';
import 'package:fitness_social_app/features/workout_planning/domain/workout_planning_repository.dart';

class WorkoutPlanningRepositoryImpl implements WorkoutPlanningRepository {
  const WorkoutPlanningRepositoryImpl(this.remote);
  final WorkoutPlanningRemoteDataSource remote;
  @override Future<WorkoutTemplate> createTemplate({required String name, required int durationDays, required bool isGeneral, required List<TemplateDayInput> days}) => remote.createTemplate(name: name, durationDays: durationDays, isGeneral: isGeneral, days: days);
  @override Future<List<WorkoutTemplate>> getTemplates() => remote.getTemplates();
  @override Future<WorkoutTemplate> getTemplate(String id) => remote.getTemplate(id);
  @override Future<void> archiveTemplate(String id) => remote.archiveTemplate(id);
  @override Future<WorkoutPlan> createPlan({required String name, required int durationDays, String? ownerUserId, required List<String> templateIds, required List<ManualPlanDayInput> days}) => remote.createPlan(name: name, durationDays: durationDays, ownerUserId: ownerUserId, templateIds: templateIds, days: days);
  @override Future<List<WorkoutPlan>> getPlans() => remote.getPlans();
  @override Future<WorkoutPlan> getPlan(String id) => remote.getPlan(id);
  @override Future<void> sendPlan(String id) => remote.sendPlan(id);
  @override Future<void> acceptPlan(String id) => remote.acceptPlan(id);
  @override Future<void> rejectPlan(String id) => remote.rejectPlan(id);
  @override Future<WorkoutPlan> startPlan(String id, DateTime startDate) => remote.startPlan(id, startDate);
  @override Future<WorkoutPlan> completeDay({required String planId, required String dayId, required int totalDurationMinutes, required String? description, required List<ExerciseMuscle> muscles, required List<UserExerciseInput> exercises}) => remote.completeDay(planId: planId, dayId: dayId, totalDurationMinutes: totalDurationMinutes, description: description, muscles: muscles, exercises: exercises);
}
