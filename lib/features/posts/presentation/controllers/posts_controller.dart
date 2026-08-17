import 'package:flutter/foundation.dart';

import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/posts/domain/entities/post.dart';
import 'package:fitness_social_app/features/posts/domain/usecases/post_usecases.dart';

class PostsController extends ChangeNotifier {
  PostsController({
    required GetFeedPosts getFeedPosts,
    required GetAllPosts getAllPosts,
    required GetPostById getPostById,
    required CreatePost createPost,
    required DeletePost deletePost,
    required TogglePostLike togglePostLike,
    required GetPostComments getPostComments,
    required AddPostComment addPostComment,
  })  : _getFeedPosts = getFeedPosts,
        _getAllPosts = getAllPosts,
        _getPostById = getPostById,
        _createPost = createPost,
        _deletePost = deletePost,
        _togglePostLike = togglePostLike,
        _getPostComments = getPostComments,
        _addPostComment = addPostComment;

  final GetFeedPosts _getFeedPosts;
  final GetAllPosts _getAllPosts;
  final GetPostById _getPostById;
  final CreatePost _createPost;
  final DeletePost _deletePost;
  final TogglePostLike _togglePostLike;
  final GetPostComments _getPostComments;
  final AddPostComment _addPostComment;

  List<Comment> _comments = const <Comment>[];
  bool _isLoadingComments = false;

  List<Post> _posts = const <Post>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Comment> get comments => _comments;
  bool get isLoadingComments => _isLoadingComments;

  Future<void> loadFeed({bool followingOnly = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = followingOnly
          ? await _getFeedPosts()
          : await _getAllPosts();
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
    } catch (_) {
      _errorMessage = 'تعذر تحميل المنشورات. حاول مرة أخرى.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updatePostAuthorName(String postId, String authorName) {
    final name = authorName.trim();
    if (name.isEmpty) return;
    final post = _posts.where((item) => item.id == postId).isEmpty
        ? null
        : _posts.firstWhere((item) => item.id == postId);
    if (post == null || post.authorName == name) return;
    _posts = _posts
        .map((item) => item.id == postId ? item.copyWith(authorName: name) : item)
        .toList(growable: false);
    notifyListeners();
  }

  Future<Post?> loadPost(String postId) async {
    try {
      return await _getPostById(postId);
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'تعذر تحميل المنشور. حاول مرة أخرى.';
      notifyListeners();
      return null;
    }
  }

  Future<Post?> createPost({
    required String content,
    String? communityId,
    List<String> mediaUrls = const <String>[],
  }) async {
    try {
      final post = await _createPost(
        content: content,
        communityId: communityId,
        mediaUrls: mediaUrls,
      );
      _posts = <Post>[post, ..._posts];
      _errorMessage = null;
      notifyListeners();
      return post;
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
    } catch (_) {
      _errorMessage = 'تعذر إنشاء المنشور. حاول مرة أخرى.';
    }
    notifyListeners();
    return null;
  }

  Future<Post?> toggleLike(Post post) async {
    try {
      final isLiked = await _togglePostLike(post.id);
      final countDelta = isLiked == post.isLikedByCurrentUser
          ? 0
          : isLiked
          ? 1
          : -1;
      final updatedPost = post.copyWith(
        isLikedByCurrentUser: isLiked,
        likesCount: post.likesCount + countDelta,
      );
      _replacePost(updatedPost);
      return updatedPost;
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'تعذر تحديث الإعجاب. حاول مرة أخرى.';
      notifyListeners();
    }
    return null;
  }

  Future<bool> deletePost(Post post) async {
    try {
      await _deletePost(post.id);
      _posts = _posts.where((item) => item.id != post.id).toList();
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
    } catch (_) {
      _errorMessage = 'تعذر حذف المنشور. حاول مرة أخرى.';
    }
    notifyListeners();
    return false;
  }

  Future<void> loadComments(String postId) async {
    _isLoadingComments = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _comments = await _getPostComments(postId);
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
    } catch (_) {
      _errorMessage = 'تعذر تحميل التعليقات. حاول مرة أخرى.';
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  Future<Comment?> addComment({
    required Post post,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final comment = await _addPostComment(
        postId: post.id,
        content: content,
        parentCommentId: parentCommentId,
      );
      _comments = <Comment>[..._comments, comment];
      _replacePost(post.copyWith(commentsCount: post.commentsCount + 1));
      notifyListeners();
      return comment;
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
    } catch (_) {
      _errorMessage = 'تعذر إضافة التعليق. حاول مرة أخرى.';
    }
    notifyListeners();
    return null;
  }

  void _replacePost(Post post) {
    _posts = _posts
        .map((item) => item.id == post.id ? post : item)
        .toList(growable: false);
    notifyListeners();
  }
}
