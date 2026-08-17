import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/posts/data/models/post_models.dart';

abstract interface class PostRemoteDataSource {
  Future<List<PostModel>> getAllPosts();

  Future<List<PostModel>> getFeedPosts();

  Future<PostModel> getPostById(String postId);

  Future<PostModel> createPost({
    required String content,
    String? communityId,
    List<String> mediaUrls,
  });

  Future<void> deletePost(String postId);

  Future<bool> toggleLike(String postId);

  Future<List<CommentModel>> getComments(
    String postId, {
    String? commentId,
    int page = 1,
    int pageSize = 10,
  });

  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  });
}

class ApiPostRemoteDataSource implements PostRemoteDataSource {
  const ApiPostRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PostModel>> getAllPosts() async {
    // The feed endpoint includes isLikedByCurrentUser for the authenticated user.
    final response = await _apiClient.getListJson('/api/Posts/feed');
    return response.map(PostModel.fromJson).toList(growable: false);
  }

  @override
  Future<List<PostModel>> getFeedPosts() async {
    final response = await _apiClient.getListJson('/api/Posts/feed');
    return response.map(PostModel.fromJson).toList(growable: false);
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    final response = await _apiClient.getJson('/api/Posts/$postId');
    return PostModel.fromJson(response);
  }

  @override
  Future<PostModel> createPost({
    required String content,
    String? communityId,
    List<String> mediaUrls = const <String>[],
  }) async {
    final response = await _apiClient.postJson(
      '/api/Posts',
      body: <String, dynamic>{
        'content': content,
        'communityId': communityId,
        'mediaUrls': mediaUrls,
      },
    );
    return PostModel.fromJson(response);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _apiClient.deleteJson('/api/Posts/$postId');
  }

  @override
  Future<bool> toggleLike(String postId) async {
    final response = await _apiClient.postJson(
      '/api/Posts/$postId/like',
      body: <String, dynamic>{},
    );
    final value = response['isLiked'] ??
        response['IsLiked'] ??
        response['isLikedByCurrentUser'] ??
        response['IsLikedByCurrentUser'];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  @override
  Future<List<CommentModel>> getComments(
    String postId, {
    String? commentId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final query = <String, String>{
      'postId': postId,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (commentId != null && commentId.trim().isNotEmpty)
        'commentId': commentId.trim(),
    };
    final uri = Uri(queryParameters: query);
    final decoded = await _apiClient.getJsonValue('/api/Comments$uri');
    final values = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
            ? (decoded['items'] ??
                    decoded['data'] ??
                    decoded['comments'] ??
                    decoded['results'] ??
                    const <dynamic>[]) as dynamic
            : const <dynamic>[];
    if (values is! List) return const <CommentModel>[];
    return values
        .whereType<Map<String, dynamic>>()
        .map(CommentModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final response = await _apiClient.postJson(
      '/api/Posts/$postId/comments',
      body: <String, dynamic>{
        'content': content,
        'parentCommentId': parentCommentId,
      },
    );
    return CommentModel.fromJson(response);
  }
}
