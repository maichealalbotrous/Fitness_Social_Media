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
  Future<String> join(String id);
  Future<String> leave(String id);
  Future<String> handleRequest({required String requestId, required bool accepted});
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
    final response = await _apiClient.getJson('/api/Community/$id');
    return CommunityModel.fromJson(response);
  }

  @override
  Future<List<CommunityModel>> getMyCommunities() async {
    final response = await _apiClient.getListJson('/api/Community/my');
    return response.map(CommunityModel.fromJson).toList(growable: false);
  }

  @override
  Future<String> join(String id) async {
    final response = await _apiClient.postJson(
      '/api/Community/$id/join?communityId=${Uri.encodeComponent(id)}',
      body: <String, dynamic>{},
    );
    return _message(response, fallback: 'تم تنفيذ طلب الانضمام.');
  }

  @override
  Future<String> leave(String id) async {
    final response = await _apiClient.deleteJson('/api/Community/$id/leave');
    return _message(response, fallback: 'تمت مغادرة المجتمع.');
  }

  @override
  Future<String> handleRequest({
    required String requestId,
    required bool accepted,
  }) async {
    final response = await _apiClient.postJson(
      '/requests/$requestId?accepted=$accepted',
      body: <String, dynamic>{},
    );
    return _message(response, fallback: 'تمت معالجة الطلب.');
  }

  String _message(Map<String, dynamic> response, {required String fallback}) {
    final value = response['message'] ?? response['Message'];
    return value is String && value.isNotEmpty ? value : fallback;
  }
}
