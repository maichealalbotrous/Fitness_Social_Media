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
    return _getUsers('/api/Follows/followers');
  }

  @override
  Future<List<FollowUser>> getFollowing() {
    return _getUsers('/api/Follows/following');
  }

  Future<List<FollowUser>> _getUsers(String path) async {
    final response = await _apiClient.getListValue(path);
    return response
        .map(_toFollowUser)
        .whereType<FollowUser>()
        .where((user) => user.userId.isNotEmpty)
        .toList(growable: false);
  }

  FollowUser? _toFollowUser(dynamic value) {
    if (value is String) {
      return FollowUser(userId: value);
    }
    if (value is! Map<String, dynamic>) return null;
    final userId = _string(value, 'userId') ?? _string(value, 'id');
    if (userId == null || userId.isEmpty) return null;
    return FollowUser(
      userId: userId,
      username: _string(value, 'username') ?? _string(value, 'name'),
    );
  }

  String? _string(Map<String, dynamic> value, String key) {
    final pascalKey = key[0].toUpperCase() + key.substring(1);
    final item = value[key] ?? value[pascalKey];
    return item is String && item.isNotEmpty ? item : null;
  }

  String _message(Map<String, dynamic> response) {
    final message = response['message'] ?? response['Message'];
    return message is String ? message : '';
  }
}
