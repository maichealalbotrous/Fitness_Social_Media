import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/posts/domain/entities/post.dart';
import 'package:fitness_social_app/features/posts/presentation/posts_dependencies.dart';
import 'package:fitness_social_app/features/posts/presentation/controllers/posts_controller.dart';
import 'package:fitness_social_app/features/posts/presentation/widgets/post_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/local_profile_avatar.dart';
import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/user_controller.dart';
import 'package:fitness_social_app/features/user/presentation/user_dependencies.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({required this.post, super.key});

  final Post post;

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late final PostsController _controller;
  late final UserController _userController;
  late Post _post;
  UserProfile? _postProfile;
  final Map<String, UserProfile> _commentProfiles = <String, UserProfile>{};
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isLoadingPost = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _controller = PostsDependencies.createController();
    _userController = UserDependencies.createController();
    _post = widget.post;
    _loadPost();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _controller.dispose();
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FeedTheme.background,
      appBar: AppBar(
        title: const Text('POST'),
        backgroundColor: FeedTheme.background,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          Stack(
            children: [
              PostCard(
                post: _post,
                onLike: _toggleLike,
                currentUserId: null,
                currentUserName: _postProfile?.username,
                authorAvatar: _postProfile?.profilePictureUrl,
              ),
              if (_isLoadingPost)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(
                      child: CircularProgressIndicator(color: FeedTheme.lime),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'COMMENTS',
            style: TextStyle(
              color: FeedTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          if (_message case final String message)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                message,
                style: const TextStyle(color: FeedTheme.muted),
              ),
            ),
          _CommentComposer(
            controller: _commentController,
            isSubmitting: _isSubmittingComment,
            onSubmit: _addComment,
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => _CommentsList(
              comments: _controller.comments,
              isLoading: _controller.isLoadingComments,
              errorMessage: _controller.errorMessage,
              profiles: _commentProfiles,
              onRetry: _loadComments,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadComments() async {
    await _controller.loadComments(_post.id);
    if (!mounted) return;
    final comments = List<Comment>.of(_controller.comments);
    final profiles = await Future.wait(
      comments.map((comment) => _userController.loadById(comment.authorId)),
    );
    if (!mounted) return;
    for (var index = 0; index < comments.length; index++) {
      final profile = profiles[index];
      if (profile != null) {
        _commentProfiles[comments[index].authorId] = profile;
      }
    }
    setState(() {});
  }

  Future<void> _loadPost() async {
    setState(() => _isLoadingPost = true);
    final loadedPost = await _controller.loadPost(widget.post.id);
    final profile = await _userController.loadById(
      (loadedPost ?? _post).authorId,
      forceRefresh: true,
    );
    if (!mounted) return;
    setState(() {
      _isLoadingPost = false;
      _postProfile = profile;
      if (loadedPost != null) {
        _post = loadedPost.copyWith(
          isLikedByCurrentUser:
              loadedPost.isLikedByCurrentUser || _post.isLikedByCurrentUser,
        );
      }
    });
  }

  Future<void> _toggleLike() async {
    final updated = await _controller.toggleLike(_post);
    if (!mounted || updated == null) return;
    setState(() => _post = updated);
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _isSubmittingComment) return;

    setState(() {
      _isSubmittingComment = true;
      _message = null;
    });
    final comment = await _controller.addComment(
      post: _post,
      content: content,
    );
    if (!mounted) return;
    setState(() {
      _isSubmittingComment = false;
      _message = comment == null ? _controller.errorMessage : 'تمت إضافة التعليق.';
    });
    if (comment != null) {
      final profile = await _userController.loadById(comment.authorId);
      if (profile != null) {
        _commentProfiles[comment.authorId] = profile;
      }
      _commentController.clear();
      setState(() {});
    }
  }
}

class _CommentsList extends StatelessWidget {
  const _CommentsList({
    required this.comments,
    required this.isLoading,
    required this.errorMessage,
    required this.profiles,
    required this.onRetry,
  });

  final List<Comment> comments;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, UserProfile> profiles;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: FeedTheme.lime),
        ),
      );
    }
    if (errorMessage != null && comments.isEmpty) {
      return Column(
        children: [
          Text(errorMessage!, style: const TextStyle(color: FeedTheme.muted)),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      );
    }
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'لا توجد تعليقات بعد.',
          style: TextStyle(color: FeedTheme.muted),
        ),
      );
    }
    return Column(
      children: comments
          .map(
            (comment) => _CommentTile(
              comment: comment,
              profile: profiles[comment.authorId],
            ),
          )
          .toList(growable: false),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, this.profile});

  final Comment comment;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FeedTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FeedTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocalProfileAvatar(
            radius: 18,
            imageUrl: profile?.profilePictureUrl,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text(
            _commentAuthor(comment, profile),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: const TextStyle(color: Colors.white70, height: 1.35),
          ),
          const SizedBox(height: 6),
          Text(
            _commentDate(comment.createdAt),
            style: const TextStyle(color: FeedTheme.muted, fontSize: 11),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _commentAuthor(Comment comment, UserProfile? profile) {
  final authorName = comment.authorName ?? profile?.username;
  if (authorName != null && authorName.isNotEmpty) return authorName;
  if (comment.authorId.isEmpty) return 'Repflow athlete';
  final suffix = comment.authorId.length > 8
      ? comment.authorId.substring(0, 8)
      : comment.authorId;
  return 'Athlete $suffix';
}

String _commentDate(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
  if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
  return 'منذ ${difference.inDays} يوم';
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'اكتب تعليقاً...',
              hintStyle: const TextStyle(color: FeedTheme.muted),
              filled: true,
              fillColor: FeedTheme.panel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: isSubmitting ? null : onSubmit,
          icon: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
        ),
      ],
    );
  }
}
