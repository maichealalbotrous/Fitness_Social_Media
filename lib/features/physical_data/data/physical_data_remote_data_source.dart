import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/physical_data/domain/physical_data_entities.dart';

abstract interface class PhysicalDataRemoteDataSource {
  Future<UserPhysicalData> get(String userId);
  Future<UserPhysicalData> update({required String userId, required double? heightCm, required PhysicalSex? sex, required DateTime? birthday, required bool heightIsPrivate, required bool weightsIsPrivate, required bool sexIsPrivate, required bool birthdayIsPrivate, required bool personalRecordsIsPrivate});
  Future<UserPhysicalData> addWeight({required String userId, required double weightKg});
}

class ApiPhysicalDataRemoteDataSource implements PhysicalDataRemoteDataSource {
  const ApiPhysicalDataRemoteDataSource(this._api);
  final ApiClient _api;

  String _path(String userId) => '/api/users/${Uri.encodeComponent(userId)}/physical-data';
  @override
  Future<UserPhysicalData> get(String userId) async => _parse(await _api.getJson(_path(userId)));
  @override
  Future<UserPhysicalData> update({required String userId, required double? heightCm, required PhysicalSex? sex, required DateTime? birthday, required bool heightIsPrivate, required bool weightsIsPrivate, required bool sexIsPrivate, required bool birthdayIsPrivate, required bool personalRecordsIsPrivate}) async => _parse(await _api.putJson(_path(userId), body: {'heightCm': heightCm, 'sex': sex?.apiValue, 'birthday': birthday?.toUtc().toIso8601String(), 'heightIsPrivate': heightIsPrivate, 'weightsIsPrivate': weightsIsPrivate, 'sexIsPrivate': sexIsPrivate, 'birthdayIsPrivate': birthdayIsPrivate, 'personalRecordsIsPrivate': personalRecordsIsPrivate}));
  @override
  Future<UserPhysicalData> addWeight({required String userId, required double weightKg}) async => _parse(await _api.postJson('${_path(userId)}/weights', body: {'weightKg': weightKg}));

  UserPhysicalData _parse(Map<String, dynamic> json) {
    List<dynamic> list(String key) => (json[key] ?? json[_pascal(key)]) is List ? (json[key] ?? json[_pascal(key)]) as List : const [];
    String value(String key) => (json[key] ?? json[_pascal(key)] ?? '').toString();
    DateTime? date(String key) => DateTime.tryParse(value(key));
    return UserPhysicalData(
      userId: value('userId'),
      heightCm: double.tryParse(value('heightCm')),
      heightIsPrivate: _bool(json, 'heightIsPrivate'),
      weights: list('weights').whereType<Map<String, dynamic>>().map((item) => WeightEntry(weightKg: double.tryParse((item['weightKg'] ?? item['WeightKg'] ?? '').toString()) ?? 0, addedAt: DateTime.tryParse((item['addedAt'] ?? item['AddedAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0))).toList(growable: false),
      weightsIsPrivate: _bool(json, 'weightsIsPrivate'),
      sex: PhysicalSexX.fromApi(value('sex')),
      sexIsPrivate: _bool(json, 'sexIsPrivate'),
      birthday: date('birthday'),
      birthdayIsPrivate: _bool(json, 'birthdayIsPrivate'),
      personalRecords: list('personalRecords').whereType<Map<String, dynamic>>().map((item) => PersonalRecord(exerciseId: (item['exerciseId'] ?? item['ExerciseId'] ?? '').toString(), exerciseName: (item['exerciseName'] ?? item['ExerciseName'] ?? 'Unknown exercise').toString(), maxWeightKg: double.tryParse((item['maxWeightKg'] ?? item['MaxWeightKg'] ?? '').toString()) ?? 0, date: DateTime.tryParse((item['date'] ?? item['Date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0))).toList(growable: false),
      personalRecordsIsPrivate: _bool(json, 'personalRecordsIsPrivate'),
    );
  }
  bool _bool(Map<String, dynamic> json, String key) => (json[key] ?? json[_pascal(key)] ?? false) == true;
  String _pascal(String key) => key[0].toUpperCase() + key.substring(1);
}
