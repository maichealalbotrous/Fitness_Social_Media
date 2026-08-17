import 'package:fitness_social_app/features/posts/domain/entities/post.dart';
import 'package:fitness_social_app/features/posts/domain/repositories/post_repository.dart';

class GetFeedPosts {
  const GetFeedPosts(this._repository);

  final PostRepository _repository;

  Future<List<Post>> call() => _repository.getFeedPosts();
}

class GetAllPosts {
  const GetAllPosts(this._repository);

  final PostRepository _repository;

  Future<List<Post>> call() => _repository.getAllPosts();
}

class GetPostById {
  const GetPostById(this._repository);

  final PostRepository _repository;

  Future<Post> call(String postId) => _repository.getPostById(postId);
}

class CreatePost {
  const CreatePost(this._repository);

  final PostRepository _repository;

  Future<Post> call({
    required String content,
    String? communityId,
    List<String> mediaUrls = const <String>[],
  }) {
    return _repository.createPost(
      content: content,
      communityId: communityId,
      mediaUrls: mediaUrls,
    );
  }
}

class DeletePost {
  const DeletePost(this._repository);

  final PostRepository _repository;

  Future<void> call(String postId) => _repository.deletePost(postId);
}

class TogglePostLike {
  const TogglePostLike(this._repository);

  final PostRepository _repository;

  Future<bool> call(String postId) => _repository.toggleLike(postId);
}

class GetPostComments {
  const GetPostComments(this._repository);

  final PostRepository _repository;

  Future<List<Comment>> call(
    String postId, {
    String? commentId,
    int page = 1,
    int pageSize = 10,
  }) {
    return _repository.getComments(
      postId,
      commentId: commentId,
      page: page,
      pageSize: pageSize,
    );
  }
}

class AddPostComment {
  const AddPostComment(this._repository);

  final PostRepository _repository;

  Future<Comment> call({
    required String postId,
    required String content,
    String? parentCommentId,
  }) {
    return _repository.addComment(
      postId: postId,
      content: content,
      parentCommentId: parentCommentId,
    );
  }
}
