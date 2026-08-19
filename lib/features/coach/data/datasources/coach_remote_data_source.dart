import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/coach/domain/entities/coach_entities.dart';

abstract interface class CoachRemoteDataSource {
  Future<CoachApplication> submitApplication(String certificationUrl);
  Future<CoachApplication?> getMyApplication();
  Future<List<CoachApplication>> getPendingApplications();
  Future<CoachApplication> reviewApplication(String id, {required bool approved, String? reviewNote});
  Future<TrainingRequest> createTrainingRequest({required String coachId, String? message});
  Future<List<TrainingRequest>> getTrainingRequests();
  Future<TrainingRequest> reviewTrainingRequest(String id, {required bool approved});
}

class ApiCoachRemoteDataSource implements CoachRemoteDataSource {
  const ApiCoachRemoteDataSource(this._api);
  final ApiClient _api;

  @override
  Future<CoachApplication> submitApplication(String certificationUrl) async => _application(await _api.postJson('/api/coach/applications', body: {'certificationUrl': certificationUrl}));
  @override
  Future<CoachApplication?> getMyApplication() async {
    try { return _application(await _api.getJson('/api/coach/applications/me')); } on ApiException catch (e) { if (e.statusCode == 404) return null; rethrow; }
  }
  @override
  Future<List<CoachApplication>> getPendingApplications() async => _applications(await _api.getJsonValue('/api/coach/applications/pending'));
  @override
  Future<CoachApplication> reviewApplication(String id, {required bool approved, String? reviewNote}) async => _application(await _api.patchJson('/api/coach/applications/${Uri.encodeComponent(id)}', body: {'approved': approved, 'reviewNote': reviewNote}));
  @override
  Future<TrainingRequest> createTrainingRequest({required String coachId, String? message}) async => _training(await _api.postJson('/api/coach/training-requests', body: {'coachId': coachId, 'message': message}));
  @override
  Future<List<TrainingRequest>> getTrainingRequests() async => _trainings(await _api.getJsonValue('/api/coach/training-requests'));
  @override
  Future<TrainingRequest> reviewTrainingRequest(String id, {required bool approved}) async => _training(await _api.patchJson('/api/coach/training-requests/${Uri.encodeComponent(id)}', body: {'approved': approved}));

  Map<String, dynamic> _map(dynamic value) => value is Map<String, dynamic> ? (value['data'] is Map<String, dynamic> ? value['data'] : value) : <String, dynamic>{};
  List<dynamic> _list(dynamic value) => value is List ? value : value is Map<String, dynamic> && value['data'] is List ? value['data'] : const [];
  String s(Map<String, dynamic> j, String k) => (j[k] ?? j[_pascal(k)] ?? '').toString();
  DateTime date(Map<String, dynamic> j, String k) => DateTime.tryParse(s(j, k)) ?? DateTime.fromMillisecondsSinceEpoch(0);
  String _pascal(String k) => k[0].toUpperCase() + k.substring(1);
  CoachApplication _application(dynamic value) { final j = _map(value); return CoachApplication(id: j['id']?.toString() ?? j['Id']?.toString(), userId: s(j, 'userId'), certificationUrl: s(j, 'certificationUrl'), status: s(j, 'status'), reviewNote: j['reviewNote']?.toString() ?? j['ReviewNote']?.toString(), submittedAt: date(j, 'submittedAt'), reviewedAt: DateTime.tryParse(s(j, 'reviewedAt'))); }
  List<CoachApplication> _applications(dynamic value) => _list(value).whereType<Map<String, dynamic>>().map(_application).toList(growable: false);
  TrainingRequest _training(dynamic value) { final j = _map(value); return TrainingRequest(id: j['id']?.toString() ?? j['Id']?.toString(), athleteId: s(j, 'athleteId'), coachId: s(j, 'coachId'), message: j['message']?.toString() ?? j['Message']?.toString(), status: s(j, 'status'), createdAt: date(j, 'createdAt'), reviewedAt: DateTime.tryParse(s(j, 'reviewedAt'))); }
  List<TrainingRequest> _trainings(dynamic value) => _list(value).whereType<Map<String, dynamic>>().map(_training).toList(growable: false);
}
