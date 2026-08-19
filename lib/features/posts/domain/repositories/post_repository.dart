import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/posts/domain/entities/post.dart';

abstract interface class PostRepository {
  Future<List<Post>> getAllPosts();

  Future<List<Post>> getFeedPosts();

  Future<Post> getPostById(String postId);

  Future<List<String>> uploadPostMedia(List<MultipartUploadFile> files);

  Future<Post> createPost({
    required String content,
    String? communityId,
    List<String> mediaUrls,
  });

  Future<void> deletePost(String postId);

  Future<bool> toggleLike(String postId);

  Future<List<Comment>> getComments(
    String postId, {
    String? commentId,
    int page = 1,
    int pageSize = 10,
  });

  Future<Comment> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  });
}
