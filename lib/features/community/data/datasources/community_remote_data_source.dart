import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/community/data/models/community_model.dart';

abstract interface class CommunityRemoteDataSource {
  Future<CommunityModel> create({
    required String name,
    String? description,
    String? imageUrl,
    required bool isPrivate,
  });

  Future<CommunityModel> getById(String id);
  Future<List<CommunityModel>> getMyCommunities();
  Future<List<CommunityMemberModel>> getMembers(String communityId);
  Future<String> join(String id);
  Future<String> leave(String id);
  Future<String> handleRequest({required String requestId, required bool accepted});
  Future<String> makeAdmin({required String communityId, required String userId});
  Future<String> removeAdmin({required String communityId, required String userId});
  Future<String> removeMember({required String communityId, required String userId});
}

class ApiCommunityRemoteDataSource implements CommunityRemoteDataSource {
  const ApiCommunityRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<CommunityModel> create({
    required String name,
    String? description,
    String? imageUrl,
    required bool isPrivate,
  }) async {
    final response = await _apiClient.postJson(
      '/api/Community',
      body: <String, dynamic>{
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'isPrivate': isPrivate,
      },
    );
    return CommunityModel.fromJson(response);
  }

  @override
  Future<CommunityModel> getById(String id) async {
    final response = await _apiClient.getJson('/api/Community/${Uri.encodeComponent(id)}');
    return CommunityModel.fromJson(response);
  }

  @override
  Future<List<CommunityModel>> getMyCommunities() async {
    final response = await _apiClient.getListJson('/api/Community/user/communities');
    return response.map(CommunityModel.fromJson).toList(growable: false);
  }

  @override
  Future<List<CommunityMemberModel>> getMembers(String communityId) async {
    final response = await _apiClient.getListJson(
      '/api/Community/${Uri.encodeComponent(communityId)}/members',
    );
    return response.map(CommunityMemberModel.fromJson).toList(growable: false);
  }

  @override
  Future<String> join(String id) async {
    final response = await _apiClient.postJson(
      '/api/Community/${Uri.encodeComponent(id)}/join?communityId=${Uri.encodeComponent(id)}',
      body: const <String, dynamic>{},
    );
    return _message(response, fallback: 'تم تنفيذ طلب الانضمام.');
  }

  @override
  Future<String> leave(String id) async {
    final response = await _apiClient.deleteJson(
      '/api/Community/${Uri.encodeComponent(id)}/leave',
    );
    return _message(response, fallback: 'تمت مغادرة المجتمع.');
  }

  @override
  Future<String> handleRequest({
    required String requestId,
    required bool accepted,
  }) async {
    final response = await _apiClient.postJson(
      '/requests/${Uri.encodeComponent(requestId)}?accepted=$accepted',
      body: const <String, dynamic>{},
    );
    return _message(response, fallback: 'تمت معالجة الطلب.');
  }

  @override
  Future<String> makeAdmin({required String communityId, required String userId}) async {
    final response = await _apiClient.patchJson(
      '/api/Community/${Uri.encodeComponent(communityId)}/make-admin/${Uri.encodeComponent(userId)}',
    );
    return _message(response, fallback: 'تمت ترقية العضو إلى إداري.');
  }

  @override
  Future<String> removeAdmin({required String communityId, required String userId}) async {
    final response = await _apiClient.patchJson(
      '/api/Community/${Uri.encodeComponent(communityId)}/remove-admin/${Uri.encodeComponent(userId)}',
    );
    return _message(response, fallback: 'تمت إزالة صلاحية الإداري.');
  }

  @override
  Future<String> removeMember({required String communityId, required String userId}) async {
    final response = await _apiClient.deleteJson(
      '/api/Community/${Uri.encodeComponent(communityId)}/remove-member/${Uri.encodeComponent(userId)}',
    );
    return _message(response, fallback: 'تمت إزالة العضو.');
  }

  String _message(Map<String, dynamic> response, {required String fallback}) {
    final value = response['message'] ?? response['Message'];
    return value is String && value.isNotEmpty ? value : fallback;
  }
}
