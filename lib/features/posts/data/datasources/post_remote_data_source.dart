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
    final response = await _apiClient.getListJson('/api/Posts');
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
    return response['isLiked'] == true || response['IsLiked'] == true;
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
