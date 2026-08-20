import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';
import 'package:fitness_social_app/features/workout_planning/domain/workout_planning_entities.dart';

abstract interface class WorkoutPlanningRepository {
  Future<WorkoutTemplate> createTemplate({required String name, required int durationDays, required bool isGeneral, required List<TemplateDayInput> days});
  Future<List<WorkoutTemplate>> getTemplates();
  Future<WorkoutTemplate> getTemplate(String id);
  Future<void> archiveTemplate(String id);
  Future<WorkoutPlan> createPlan({required String name, required int durationDays, String? ownerUserId, required List<String> templateIds, required List<ManualPlanDayInput> days});
  Future<List<WorkoutPlan>> getPlans();
  Future<WorkoutPlan> getPlan(String id);
  Future<void> sendPlan(String id);
  Future<void> acceptPlan(String id);
  Future<void> rejectPlan(String id);
  Future<WorkoutPlan> startPlan(String id, DateTime startDate);
  Future<WorkoutPlan> completeDay({required String planId, required String dayId, required int totalDurationMinutes, required String? description, required List<ExerciseMuscle> muscles, required List<UserExerciseInput> exercises});
}
