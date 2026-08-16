import 'package:fitness_social_app/features/posts/domain/entities/post.dart';

abstract interface class PostRepository {
  Future<List<Post>> getAllPosts();

  Future<List<Post>> getFeedPosts();

  Future<Post> getPostById(String postId);

  Future<Post> createPost({
    required String content,
    String? communityId,
    List<String> mediaUrls,
  });

  Future<void> deletePost(String postId);

  Future<bool> toggleLike(String postId);

  Future<List<Comment>> getComments(String postId);

  Future<Comment> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  });
}
