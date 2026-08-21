import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/coach/domain/entities/coach_entities.dart';

abstract interface class CoachRemoteDataSource {
  Future<String> uploadCertification({required List<int> bytes, required String fileName});
  Future<CoachApplication> submitApplication(String certificationUrl);
  Future<CoachApplication?> getMyApplication();
  Future<List<CoachApplication>> getPendingApplications();
  Future<CoachApplication> reviewApplication(String id, {required bool approved, String? reviewNote});
  Future<List<CoachProfile>> getAllCoaches();
  Future<List<CoachProfile>> getTopRatedCoaches();
  Future<List<CoachProfile>> findCoachesByName(String name);
  Future<List<CoachProfile>> getParticipantCoaches(String participantId);
  Future<void> rateCoach(String coachId, int rating);
  Future<TrainingRequest> createTrainingRequest({required String coachId, String? message});
  Future<List<TrainingRequest>> getTrainingRequests();
  Future<TrainingRequest> reviewTrainingRequest(String id, {required bool approved});
  Future<CoachUser> getUser(String userId);
}

class ApiCoachRemoteDataSource implements CoachRemoteDataSource {
  const ApiCoachRemoteDataSource(this._api);
  final ApiClient _api;

  @override
  Future<String> uploadCertification({required List<int> bytes, required String fileName}) async {
    final response = await _api.postMultipartFiles('/api/Media/upload-post-media', fieldName: 'files', files: [MultipartUploadFile(fileName: fileName, bytes: bytes)]);
    final urls = response['urls'] ?? response['Urls'];
    if (urls is List && urls.isNotEmpty) return urls.first.toString();
    throw const ApiException(message: 'The server did not return the uploaded image URL.');
  }

  @override
  Future<CoachApplication> submitApplication(String certificationUrl) async => _application(await _api.postJson('/api/coach/applications', body: {'certificationUrl': certificationUrl}));
  @override
  Future<CoachApplication?> getMyApplication() async { try { return _application(await _api.getJson('/api/coach/applications/me')); } on ApiException catch (e) { if (e.statusCode == 404) return null; rethrow; } }
  @override
  Future<List<CoachApplication>> getPendingApplications() async => _applications(await _api.getJsonValue('/api/coach/applications/pending'));
  @override
  Future<CoachApplication> reviewApplication(String id, {required bool approved, String? reviewNote}) async => _application(await _api.patchJson('/api/coach/applications/${Uri.encodeComponent(id)}', body: {'approved': approved, 'reviewNote': reviewNote}));
  @override
  Future<List<CoachProfile>> getAllCoaches() async => _coaches(await _api.getJsonValue('/api/coach'));
  @override
  Future<List<CoachProfile>> getTopRatedCoaches() async => _coaches(await _api.getJsonValue('/api/coach/top-rated'));
  @override
  Future<List<CoachProfile>> findCoachesByName(String name) async => _coaches(await _api.getJsonValue('/api/coach/name/${Uri.encodeComponent(name)}'));
  @override
  Future<List<CoachProfile>> getParticipantCoaches(String participantId) async => _coaches(await _api.getJsonValue('/api/coach/participant/${Uri.encodeComponent(participantId)}'));
  @override
  Future<void> rateCoach(String coachId, int rating) async { await _api.postJson('/api/coach/${Uri.encodeComponent(coachId)}/rate', body: {'rating': rating}); }
  @override
  Future<TrainingRequest> createTrainingRequest({required String coachId, String? message}) async => _training(await _api.postJson('/api/coach/training-requests', body: {'coachId': coachId, 'message': message}));
  @override
  Future<List<TrainingRequest>> getTrainingRequests() async => _trainings(await _api.getJsonValue('/api/coach/training-requests'));
  @override
  Future<TrainingRequest> reviewTrainingRequest(String id, {required bool approved}) async => _training(await _api.patchJson('/api/coach/training-requests/${Uri.encodeComponent(id)}', body: {'approved': approved}));
  @override
  Future<CoachUser> getUser(String userId) async {
    final json = await _api.getJson('/api/Users/${Uri.encodeComponent(userId)}');
    final item = _map(json);
    return CoachUser(id: s(item, 'id'), username: s(item, 'username').isEmpty ? userId : s(item, 'username'));
  }

  Map<String, dynamic> _map(dynamic value) { if (value is! Map<String, dynamic>) return <String, dynamic>{}; for (final key in const ['data','request','trainingRequest','application','coach']) { final nested = value[key]; if (nested is Map<String, dynamic>) return nested; } return value; }
  List<dynamic> _list(dynamic value) { if (value is List) return value; if (value is Map<String, dynamic>) { for (final key in const ['data','coaches','items','results','requests','trainingRequests']) { final nested = value[key]; if (nested is List) return nested; } } return const []; }
  String s(Map<String, dynamic> j, String k) => (j[k] ?? j[_pascal(k)] ?? '').toString();
  DateTime date(Map<String, dynamic> j, String k) => DateTime.tryParse(s(j, k)) ?? DateTime.fromMillisecondsSinceEpoch(0);
  String _pascal(String k) => k[0].toUpperCase() + k.substring(1);
  CoachApplication _application(dynamic value) { final j = _map(value); return CoachApplication(id: j['id']?.toString() ?? j['Id']?.toString(), userId: s(j,'userId'), certificationUrl: s(j,'certificationUrl'), status: s(j,'status'), reviewNote: j['reviewNote']?.toString() ?? j['ReviewNote']?.toString(), submittedAt: date(j,'submittedAt'), reviewedAt: DateTime.tryParse(s(j,'reviewedAt'))); }
  List<CoachApplication> _applications(dynamic value) => _list(value).whereType<Map<String,dynamic>>().map(_application).toList(growable: false);
  CoachProfile _coach(dynamic value) { final j = _map(value); return CoachProfile(userId: s(j,'userId'), username: s(j,'username'), bio: j['bio']?.toString() ?? j['Bio']?.toString(), profilePictureUrl: j['profilePictureUrl']?.toString() ?? j['ProfilePictureUrl']?.toString(), certificationUrl: s(j,'certificationUrl'), approvedAt: date(j,'approvedAt'), averageRating: double.tryParse(s(j,'averageRating')) ?? 0, totalParticipants: int.tryParse(s(j,'totalParticipants')) ?? 0); }
  List<CoachProfile> _coaches(dynamic value) => _list(value).whereType<Map<String,dynamic>>().map(_coach).toList(growable: false);
  TrainingRequest _training(dynamic value) { final j = _map(value); return TrainingRequest(id: j['id']?.toString() ?? j['Id']?.toString(), athleteId: s(j,'athleteId'), coachId: s(j,'coachId'), message: j['message']?.toString() ?? j['Message']?.toString(), status: s(j,'status'), createdAt: date(j,'createdAt'), reviewedAt: DateTime.tryParse(s(j,'reviewedAt'))); }
  List<TrainingRequest> _trainings(dynamic value) => _list(value).whereType<Map<String,dynamic>>().map(_training).toList(growable: false);
}
