import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/follows/domain/entities/follow.dart';

abstract interface class FollowRemoteDataSource {
  Future<FollowStatus> toggleFollow(String targetUserId);

  Future<List<FollowUser>> getFollowers();

  Future<List<FollowUser>> getFollowing();
}

class ApiFollowRemoteDataSource implements FollowRemoteDataSource {
  const ApiFollowRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<FollowStatus> toggleFollow(String targetUserId) async {
    final response = await _apiClient.postJson(
      '/api/Follows/$targetUserId',
      body: <String, dynamic>{},
    );
    return FollowStatus(
      isFollowing: response['isFollowing'] == true || response['IsFollowing'] == true,
      message: _message(response),
    );
  }

  @override
  Future<List<FollowUser>> getFollowers() {
    return _getUserIds('/api/Follows/followers');
  }

  @override
  Future<List<FollowUser>> getFollowing() {
    return _getUserIds('/api/Follows/following');
  }

  Future<List<FollowUser>> _getUserIds(String path) async {
    final response = await _apiClient.getStringList(path);
    return response
        .map((userId) => FollowUser(userId: userId))
        .where((user) => user.userId.isNotEmpty)
        .toList(growable: false);
  }

  String _message(Map<String, dynamic> response) {
    final message = response['message'] ?? response['Message'];
    return message is String ? message : '';
  }
}
