import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/posts/domain/entities/post.dart';
import 'package:fitness_social_app/features/posts/presentation/posts_dependencies.dart';
import 'package:fitness_social_app/features/posts/presentation/controllers/posts_controller.dart';
import 'package:fitness_social_app/features/posts/presentation/widgets/post_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({required this.post, super.key});

  final Post post;

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late final PostsController _controller;
  late Post _post;
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isLoadingPost = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _controller = PostsDependencies.createController();
    _post = widget.post;
    _loadPost();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _controller.dispose();
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
          const Text(
            'سيتم عرض التعليقات الموجودة عند توفير endpoint جلب التعليقات في الباك-إند.',
            style: TextStyle(color: FeedTheme.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPost() async {
    setState(() => _isLoadingPost = true);
    final loadedPost = await _controller.loadPost(widget.post.id);
    if (!mounted) return;
    setState(() {
      _isLoadingPost = false;
      if (loadedPost != null) _post = loadedPost;
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
    if (comment != null) _commentController.clear();
  }
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
