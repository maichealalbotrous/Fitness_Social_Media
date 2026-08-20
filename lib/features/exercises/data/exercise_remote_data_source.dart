import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';

abstract interface class ExerciseRemoteDataSource {
  Future<List<Exercise>> getAll();
  Future<List<String>> getMuscles();
  Future<List<Exercise>> getByMainMuscle(ExerciseMuscle muscle);
  Future<List<Exercise>> getBySecondaryMuscle(ExerciseMuscle muscle);
  Future<Exercise?> getById(String id);
  Future<Exercise> create({required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles});
  Future<Exercise> update({required String id, required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles});
  Future<void> delete(String id);
}

class ApiExerciseRemoteDataSource implements ExerciseRemoteDataSource {
  const ApiExerciseRemoteDataSource(this._api);
  final ApiClient _api;

  @override
  Future<List<Exercise>> getAll() async => _exercises(await _api.getJsonValue('/api/Exercises'));
  @override
  Future<List<String>> getMuscles() async => _api.getStringList('/api/Exercises/muscles');
  @override
  Future<List<Exercise>> getByMainMuscle(ExerciseMuscle muscle) async => _exercises(await _api.getJsonValue('/api/Exercises/main-muscle/${Uri.encodeComponent(muscle.apiValue)}'));
  @override
  Future<List<Exercise>> getBySecondaryMuscle(ExerciseMuscle muscle) async => _exercises(await _api.getJsonValue('/api/Exercises/secondary-muscle/${Uri.encodeComponent(muscle.apiValue)}'));
  @override
  Future<Exercise?> getById(String id) async {
    try { return _exercise(await _api.getJson('/api/Exercises/${Uri.encodeComponent(id)}')); } on ApiException catch (error) { if (error.statusCode == 404) return null; rethrow; }
  }
  @override
  Future<Exercise> create({required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles}) async => _exercise(await _api.postJson('/api/Exercises', body: _body(name, description, mainMuscle, secondaryMuscles)));
  @override
  Future<Exercise> update({required String id, required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles}) async => _exercise(await _api.putJson('/api/Exercises/${Uri.encodeComponent(id)}', body: _body(name, description, mainMuscle, secondaryMuscles)));
  @override
  Future<void> delete(String id) async { await _api.deleteJson('/api/Exercises/${Uri.encodeComponent(id)}'); }

  Map<String, dynamic> _body(String name, String description, ExerciseMuscle main, List<ExerciseMuscle> secondary) => {'name': name, 'description': description, 'mainMuscle': main.apiValue, 'secondaryMuscles': secondary.map((item) => item.apiValue).toList(growable: false)};
  List<Exercise> _exercises(dynamic value) { final list = value is List ? value : value is Map<String, dynamic> ? (value['data'] ?? value['items'] ?? const []) : const []; return list is List ? list.whereType<Map<String, dynamic>>().map(_exercise).toList(growable: false) : const []; }
  Exercise _exercise(Map<String, dynamic> json) => Exercise(id: (json['id'] ?? json['Id'] ?? '').toString(), name: (json['name'] ?? json['Name'] ?? '').toString(), description: (json['description'] ?? json['Description'] ?? '').toString(), mainMuscle: ExerciseMuscleX.fromApi((json['mainMuscle'] ?? json['MainMuscle'])?.toString()) ?? ExerciseMuscle.fullBody, secondaryMuscles: ((json['secondaryMuscles'] ?? json['SecondaryMuscles']) is List ? ((json['secondaryMuscles'] ?? json['SecondaryMuscles']) as List).map((item) => ExerciseMuscleX.fromApi(item.toString())).whereType<ExerciseMuscle>().toList(growable: false) : const []));
}
