import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/community/data/models/community_model.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';

abstract interface class CommunityRemoteDataSource {
  Future<CommunityModel> create({
    required String name,
    String? description,
    String? imageUrl,
    required bool isPrivate,
  });

  Future<CommunityModel> getById(String id);
  Future<CommunityModel> getByName(String name);
  Future<List<CommunityJoinRequest>> getRequests(String communityId);
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
  Future<CommunityModel> getByName(String name) async {
    final response = await _apiClient.getJson('/name/${Uri.encodeComponent(name.trim())}');
    return CommunityModel.fromJson(response);
  }

  @override
  Future<List<CommunityJoinRequest>> getRequests(String communityId) async {
    final value = await _apiClient.getJsonValue('/api/Community/${Uri.encodeComponent(communityId)}/requests');
    final raw = value is List ? value : value is Map<String, dynamic> ? (value['data'] ?? value['requests'] ?? const []) : const [];
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((json) => CommunityJoinRequest(
      id: (json['id'] ?? json['Id'] ?? '').toString(), communityId: (json['communityId'] ?? json['CommunityId'] ?? '').toString(), userId: (json['userId'] ?? json['UserId'] ?? '').toString(), username: (json['username'] ?? json['Username'] ?? '').toString(), imageUrl: json['imageUrl'] ?? json['ImageUrl'],
    )).toList(growable: false);
  }

  @override
  Future<List<CommunityModel>> getMyCommunities() async {
    final value = await _apiClient.getJsonValue('/api/Community/user/communities');
    return _listOfMaps(value, const ['communities', 'Communities', 'data', 'Data'])
        .map(CommunityModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<CommunityMemberModel>> getMembers(String communityId) async {
    final value = await _apiClient.getJsonValue(
      '/api/Community/${Uri.encodeComponent(communityId)}/members',
    );
    final raw = value is List
        ? value
        : value is Map<String, dynamic>
            ? (value['members'] ?? value['Members'] ?? value['data'] ?? value['Data'] ?? const [])
            : const [];
    if (raw is! List) return const <CommunityMemberModel>[];
    return raw.map((item) {
      if (item is Map<String, dynamic>) return CommunityMemberModel.fromJson(item);
      return CommunityMemberModel(userId: item.toString(), userName: item.toString(), isAdmin: false);
    }).toList(growable: false);
  }

  @override
  Future<String> join(String id) async {
    final response = await _apiClient.postJson(
      '/api/Community/${Uri.encodeComponent(id)}/join?communityId=${Uri.encodeComponent(id)}',
      body: const <String, dynamic>{},
    );
    return _message(response, fallback: 'Join request processed.');
  }

  @override
  Future<String> leave(String id) async {
    final response = await _apiClient.deleteJson(
      '/api/Community/${Uri.encodeComponent(id)}/leave',
    );
    return _message(response, fallback: 'You left the community.');
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
    return _message(response, fallback: 'Request processed.');
  }

  @override
  Future<String> makeAdmin({required String communityId, required String userId}) async {
    final response = await _apiClient.patchJson(
      '/api/Community/${Uri.encodeComponent(communityId)}/make-admin/${Uri.encodeComponent(userId)}',
    );
    return _message(response, fallback: 'Member promoted to administrator.');
  }

  @override
  Future<String> removeAdmin({required String communityId, required String userId}) async {
    final response = await _apiClient.patchJson(
      '/api/Community/${Uri.encodeComponent(communityId)}/remove-admin/${Uri.encodeComponent(userId)}',
    );
    return _message(response, fallback: 'Administrator privileges removed.');
  }

  @override
  Future<String> removeMember({required String communityId, required String userId}) async {
    final response = await _apiClient.deleteJson(
      '/api/Community/${Uri.encodeComponent(communityId)}/remove-member/${Uri.encodeComponent(userId)}',
    );
    return _message(response, fallback: 'Member removed.');
  }

  List<Map<String, dynamic>> _listOfMaps(dynamic value, List<String> wrapperKeys) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    if (value is Map<String, dynamic>) {
      for (final key in wrapperKeys) {
        final nested = value[key];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList(growable: false);
        }
      }
    }
    throw const ApiException(message: 'Invalid community list response.');
  }

  String _message(Map<String, dynamic> response, {required String fallback}) {
    final value = response['message'] ?? response['Message'];
    return value is String && value.isNotEmpty ? value : fallback;
  }
}
