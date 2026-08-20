import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';

abstract interface class UserSessionRemoteDataSource {
  Future<List<UserSession>> getAll();
  Future<List<UserSession>> getByDay(DateTime date);
  Future<List<UserSession>> getByMonth(int year, int month);
  Future<UserSession> create({required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises});
  Future<UserSession> update({required String id, required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises});
}

class ApiUserSessionRemoteDataSource implements UserSessionRemoteDataSource {
  const ApiUserSessionRemoteDataSource(this._api);
  final ApiClient _api;

  @override
  Future<List<UserSession>> getAll() async => _parseList(await _api.getListJson('/api/UserSessions'));
  @override
  Future<List<UserSession>> getByDay(DateTime date) async => _parseList(await _api.getListJson('/api/UserSessions/day/${_date(date)}'));
  @override
  Future<List<UserSession>> getByMonth(int year, int month) async => _parseList(await _api.getListJson('/api/UserSessions/month/$year/$month'));
  @override
  Future<UserSession> create({required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises}) async => _parse(await _api.postJson('/api/UserSessions', body: _body(description, muscles, totalDurationMinutes, exercises)));
  @override
  Future<UserSession> update({required String id, required String? description, required List<ExerciseMuscle> muscles, required int totalDurationMinutes, required List<UserExerciseInput> exercises}) async => _parse(await _api.putJson('/api/UserSessions/${Uri.encodeComponent(id)}', body: _body(description, muscles, totalDurationMinutes, exercises)));

  Map<String, dynamic> _body(String? description, List<ExerciseMuscle> muscles, int duration, List<UserExerciseInput> exercises) => {'description': description, 'muscles': muscles.map((item) => item.apiValue).toList(growable: false), 'totalDurationMinutes': duration, 'exercises': exercises.map((item) => item.toJson()).toList(growable: false)};
  String _date(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  List<UserSession> _parseList(dynamic json) => (json is List ? json : const []).whereType<Map<String, dynamic>>().map(_parse).toList(growable: false);
  UserSession _parse(Map<String, dynamic> json) {
    dynamic raw(String key) => json[key] ?? json[key[0].toUpperCase() + key.substring(1)];
    final list = (dynamic value) => value is List ? value : const [];
    final muscles = list(raw('muscles')).map((item) => ExerciseMuscleX.fromApi(item.toString())).whereType<ExerciseMuscle>().toList(growable: false);
    final exercises = list(raw('exercises')).whereType<Map<String, dynamic>>().map((item) => UserExerciseRecord(id: (item['id'] ?? item['Id'] ?? '').toString(), exerciseId: (item['exerciseId'] ?? item['ExerciseId'] ?? '').toString(), exerciseName: (item['exerciseName'] ?? item['ExerciseName'] ?? 'Unknown exercise').toString(), exerciseDescription: (item['exerciseDescription'] ?? item['ExerciseDescription'] ?? '').toString(), mainMuscle: ExerciseMuscleX.fromApi((item['mainMuscle'] ?? item['MainMuscle'] ?? '').toString()) ?? ExerciseMuscle.fullBody, secondaryMuscles: list(item['secondaryMuscles'] ?? item['SecondaryMuscles']).map((value) => ExerciseMuscleX.fromApi(value.toString())).whereType<ExerciseMuscle>().toList(growable: false), reps: int.tryParse((item['reps'] ?? item['Reps'] ?? '').toString()) ?? 0, sets: int.tryParse((item['sets'] ?? item['Sets'] ?? '').toString()) ?? 0, weight: double.tryParse((item['weight'] ?? item['Weight'] ?? '').toString()) ?? 0, isPr: (item['isPr'] ?? item['IsPr'] ?? false) == true)).toList(growable: false);
    final rawDate = raw('date');
    return UserSession(id: (raw('id') ?? '').toString(), userId: (raw('userId') ?? '').toString(), description: raw('description')?.toString(), muscles: muscles, date: DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(), totalDuration: (raw('totalDuration') ?? raw('TotalDuration') ?? '').toString(), exercises: exercises);
  }
}
