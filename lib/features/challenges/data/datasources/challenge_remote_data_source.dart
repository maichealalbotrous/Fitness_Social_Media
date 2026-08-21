import 'package:fitness_social_app/core/network/api_client.dart';

import '../models/challenge_model.dart';

abstract interface class ChallengeRemoteDataSource {
  Future<List<ChallengeModel>> getJoinable();
  Future<List<ChallengeModel>> getUserChallenges();
  Future<List<ChallengeModel>> getByCommunity(String communityId);
  Future<List<ChallengeModel>> getActiveByCommunity(String communityId);
  Future<ChallengeModel> getById(String challengeId);
  Future<ChallengeModel> create(String communityId, Map<String, dynamic> body);
  Future<String> join(String challengeId);
  Future<String> updateParticipant(String challengeId, double progress);
}

class ApiChallengeRemoteDataSource implements ChallengeRemoteDataSource {
  const ApiChallengeRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<ChallengeModel>> getJoinable() async => _list('/api/Challenge/user/joinable');

  @override
  Future<List<ChallengeModel>> getUserChallenges() async => _list('/api/Challenge/user');

  @override
  Future<List<ChallengeModel>> getByCommunity(String communityId) async =>
      _list('/api/Challenge/community/$communityId');

  @override
  Future<List<ChallengeModel>> getActiveByCommunity(String communityId) async =>
      _list('/api/Challenge/community/$communityId/active');

  @override
  Future<ChallengeModel> getById(String challengeId) async {
    final response = await _apiClient.getJson('/api/Challenge/$challengeId');
    return ChallengeModel.fromJson(_unwrapChallenge(response));
  }

  @override
  Future<ChallengeModel> create(String communityId, Map<String, dynamic> body) async {
    final response = await _apiClient.postJson(
      '/api/Challenge/$communityId/create',
      body: body,
    );
    return ChallengeModel.fromJson(response);
  }

  @override
  Future<String> join(String challengeId) async {
    final response = await _apiClient.postJson(
      '/api/Challenge/$challengeId/join',
      body: const <String, dynamic>{},
    );
    return _message(response, fallback: 'Challenge join request sent.');
  }

  @override
  Future<String> updateParticipant(String challengeId, double progress) async {
    final response = await _apiClient.putJsonValue(
      '/api/Challenge/$challengeId/update-participant',
      body: progress,
    );
    if (response is Map<String, dynamic>) {
      return _message(response, fallback: 'Your challenge progress was updated.');
    }
    return 'Your challenge progress was updated.';
  }

  Map<String, dynamic> _unwrapChallenge(Map<String, dynamic> response) {
    final value = response['data'] ?? response['challenge'] ?? response['Challenge'];
    return value is Map<String, dynamic> ? value : response;
  }

  Future<List<ChallengeModel>> _list(String path) async {
    final value = await _apiClient.getJsonValue(path);
    final raw = value is List
        ? value
        : value is Map<String, dynamic>
            ? (value['data'] ?? value['items'] ?? value['challenges'] ?? const [])
            : const [];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ChallengeModel.fromJson)
        .toList(growable: false);
  }

  String _message(Map<String, dynamic> response, {required String fallback}) {
    final value = response['message'] ?? response['Message'];
    return value?.toString().trim().isNotEmpty == true ? value.toString() : fallback;
  }
}
