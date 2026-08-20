import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';
import 'package:fitness_social_app/features/workout_planning/domain/workout_planning_entities.dart';

abstract interface class WorkoutPlanningRemoteDataSource {
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

class ApiWorkoutPlanningRemoteDataSource implements WorkoutPlanningRemoteDataSource {
  const ApiWorkoutPlanningRemoteDataSource(this._api);
  final ApiClient _api;
  static const _base = '/api/workout-planning';

  @override Future<WorkoutTemplate> createTemplate({required String name, required int durationDays, required bool isGeneral, required List<TemplateDayInput> days}) async => _template(await _api.postJson('$_base/templates', body: {'name': name, 'durationDays': durationDays, 'isGeneral': isGeneral, 'days': days.map((item) => item.toJson()).toList(growable: false)}));
  @override Future<List<WorkoutTemplate>> getTemplates() async => (await _api.getListJson('$_base/templates')).map(_template).toList(growable: false);
  @override Future<WorkoutTemplate> getTemplate(String id) async => _template(await _api.getJson('$_base/templates/${Uri.encodeComponent(id)}'));
  @override Future<void> archiveTemplate(String id) async { await _api.deleteJson('$_base/templates/${Uri.encodeComponent(id)}'); }
  @override Future<WorkoutPlan> createPlan({required String name, required int durationDays, String? ownerUserId, required List<String> templateIds, required List<ManualPlanDayInput> days}) async => _plan(await _api.postJson('$_base/plans', body: {'name': name, 'durationDays': durationDays, 'ownerUserId': ownerUserId, 'templateIds': templateIds, 'days': days.map((item) => item.toJson()).toList(growable: false)}));
  @override Future<List<WorkoutPlan>> getPlans() async => (await _api.getListJson('$_base/plans')).map(_plan).toList(growable: false);
  @override Future<WorkoutPlan> getPlan(String id) async => _plan(await _api.getJson('$_base/plans/${Uri.encodeComponent(id)}'));
  @override Future<void> sendPlan(String id) async { await _api.postJson('$_base/plans/${Uri.encodeComponent(id)}/send', body: const {}); }
  @override Future<void> acceptPlan(String id) async { await _api.postJson('$_base/plans/${Uri.encodeComponent(id)}/accept', body: const {}); }
  @override Future<void> rejectPlan(String id) async { await _api.postJson('$_base/plans/${Uri.encodeComponent(id)}/reject', body: const {}); }
  @override Future<WorkoutPlan> startPlan(String id, DateTime startDate) async => _plan(await _api.postJson('$_base/plans/${Uri.encodeComponent(id)}/start', body: {'startDate': _date(startDate)}));
  @override Future<WorkoutPlan> completeDay({required String planId, required String dayId, required int totalDurationMinutes, required String? description, required List<ExerciseMuscle> muscles, required List<UserExerciseInput> exercises}) async => _plan(await _api.postJson('$_base/plans/${Uri.encodeComponent(planId)}/days/${Uri.encodeComponent(dayId)}/complete', body: {'totalDurationMinutes': totalDurationMinutes, 'description': description, 'muscles': muscles.map((item) => item.apiValue).toList(growable: false), 'exercises': exercises.map((item) => item.toJson()).toList(growable: false)}));

  String _date(DateTime value) => '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  WorkoutTemplate _template(Map<String, dynamic> json) => WorkoutTemplate(id: _string(json, 'id'), userId: _string(json, 'userId'), name: _string(json, 'name'), durationDays: _int(json, 'durationDays'), isGeneral: _bool(json, 'isGeneral'), days: _days(json['days'] ?? json['Days'], template: true));
  WorkoutPlan _plan(Map<String, dynamic> json) { final plan = (json['plan'] ?? json['Plan']) is Map<String, dynamic> ? (json['plan'] ?? json['Plan']) as Map<String, dynamic> : json; return WorkoutPlan(id: _string(plan, 'id'), ownerUserId: _string(plan, 'ownerUserId'), createdByUserId: _string(plan, 'createdByUserId'), coachId: _nullable(plan, 'coachId'), name: _string(plan, 'name'), durationDays: _int(plan, 'durationDays'), status: WorkoutPlanStatusX.fromApi(_string(plan, 'status')), startDate: DateTime.tryParse(_string(plan, 'startDate')), isArchived: _bool(plan, 'isArchived'), createdAt: DateTime.tryParse(_string(plan, 'createdAt')), days: _days(json['days'] ?? json['Days'])); }
  List<WorkoutDay> _days(dynamic raw, {bool template = false}) => (raw is List ? raw : const []).whereType<Map<String, dynamic>>().map((item) => WorkoutDay(id: _string(item, 'id'), order: _int(item, 'order'), date: DateTime.tryParse(_string(item, 'date')), name: _string(item, 'name'), isRestDay: _bool(item, 'isRestDay'), exercises: _planned(item['exercises'] ?? item['Exercises']), completed: _bool(item, 'completed'), userSessionId: _nullable(item, 'userSessionId'))).toList(growable: false);
  List<PlannedExercise> _planned(dynamic raw) => (raw is List ? raw : const []).whereType<Map<String, dynamic>>().map((item) => PlannedExercise(exerciseId: _string(item, 'exerciseId'), exerciseName: _string(item, 'exerciseName'), order: _int(item, 'order'), plannedSets: _int(item, 'plannedSets'), plannedReps: _int(item, 'plannedReps'), plannedWeight: _double(item, 'plannedWeight'))).toList(growable: false);
  String _string(Map<String, dynamic> json, String key) => (json[key] ?? json[key[0].toUpperCase() + key.substring(1)] ?? '').toString();
  String? _nullable(Map<String, dynamic> json, String key) { final value = json[key] ?? json[key[0].toUpperCase() + key.substring(1)]; return value?.toString(); }
  int _int(Map<String, dynamic> json, String key) => int.tryParse(_string(json, key)) ?? 0;
  double _double(Map<String, dynamic> json, String key) => double.tryParse(_string(json, key)) ?? 0;
  bool _bool(Map<String, dynamic> json, String key) => (json[key] ?? json[key[0].toUpperCase() + key.substring(1)] ?? false) == true;
}
