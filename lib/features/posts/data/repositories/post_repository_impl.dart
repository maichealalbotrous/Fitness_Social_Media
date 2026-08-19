import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:fitness_social_app/features/posts/domain/entities/post.dart';
import 'package:fitness_social_app/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl(this._remoteDataSource);

  final PostRemoteDataSource _remoteDataSource;

  @override
  Future<List<Post>> getAllPosts() async {
    final posts = await _remoteDataSource.getAllPosts();
    return posts.map((post) => post.toEntity()).toList(growable: false);
  }

  @override
  Future<List<Post>> getFeedPosts() async {
    final posts = await _remoteDataSource.getFeedPosts();
    return posts.map((post) => post.toEntity()).toList(growable: false);
  }

  @override
  Future<Post> getPostById(String postId) async {
    final post = await _remoteDataSource.getPostById(postId);
    return post.toEntity();
  }

  @override
  Future<List<String>> uploadPostMedia(List<MultipartUploadFile> files) {
    return _remoteDataSource.uploadPostMedia(files);
  }

  @override
  Future<Post> createPost({
    required String content,
    String? communityId,
    List<String> mediaUrls = const <String>[],
  }) async {
    final post = await _remoteDataSource.createPost(
      content: content,
      communityId: communityId,
      mediaUrls: mediaUrls,
    );
    return post.toEntity();
  }

  @override
  Future<void> deletePost(String postId) {
    return _remoteDataSource.deletePost(postId);
  }

  @override
  Future<bool> toggleLike(String postId) {
    return _remoteDataSource.toggleLike(postId);
  }

  @override
  Future<List<Comment>> getComments(
    String postId, {
    String? commentId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final comments = await _remoteDataSource.getComments(
      postId,
      commentId: commentId,
      page: page,
      pageSize: pageSize,
    );
    return comments.map((comment) => comment.toEntity()).toList(growable: false);
  }

  @override
  Future<Comment> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final comment = await _remoteDataSource.addComment(
      postId: postId,
      content: content,
      parentCommentId: parentCommentId,
    );
    return comment.toEntity();
  }
}
