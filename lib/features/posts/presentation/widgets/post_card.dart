import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/posts/domain/entities/post.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/post_widgets.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.onLike,
    this.onDelete,
    this.onComment,
    this.onAuthorTap,
    this.currentUserId,
    this.currentUserName,
    this.currentUserAvatar,
    super.key,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback? onDelete;
  final VoidCallback? onComment;
  final VoidCallback? onAuthorTap;
  final String? currentUserId;
  final String? currentUserName;
  final String? currentUserAvatar;

  @override
  Widget build(BuildContext context) {
    return PostShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(
            name: _authorLabel(
              post,
              currentUserId: currentUserId,
              currentUserName: currentUserName,
            ),
            avatarBase64: post.authorId == currentUserId ? currentUserAvatar : null,
            subtitle: _formatDate(post.createdAt),
            onTap: onAuthorTap,
            action: onDelete == null
                ? null
                : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: FeedTheme.muted),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف المنشور'),
                      ),
                    ],
                  ),
          ),
          _PostContent(post: post),
          PostActions(
            likesCount: post.likesCount,
            commentsCount: post.commentsCount,
            isLiked: post.isLikedByCurrentUser,
            onLike: onLike,
            onComment: onComment,
          ),
        ],
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  const _PostContent({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Text(
              post.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
        ...post.mediaUrls.map((url) => _PostMedia(url: url)),
      ],
    );
  }
}

class _PostMedia extends StatelessWidget {
  const _PostMedia({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (!url.startsWith('data:')) {
      return Image.network(
        url,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _MediaPlaceholder(),
      );
    }

    final separator = url.indexOf(',');
    if (separator < 0) return const _MediaPlaceholder();
    try {
      final bytes = base64Decode(url.substring(separator + 1));
      return Image.memory(
        bytes,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _MediaPlaceholder(),
      );
    } catch (_) {
      return const _MediaPlaceholder();
    }
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: FeedTheme.panelDark,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: FeedTheme.muted,
        size: 32,
      ),
    );
  }
}

String _authorLabel(
  Post post, {
  String? currentUserId,
  String? currentUserName,
}) {
  if (currentUserId != null &&
      post.authorId == currentUserId &&
      currentUserName != null) {
    return currentUserName;
  }
  final authorName = post.authorName;
  if (authorName != null && authorName.isNotEmpty) {
    return authorName;
  }
  if (post.authorId.isEmpty) {
    return 'Repflow athlete';
  }
  final suffix = post.authorId.length > 8
      ? post.authorId.substring(0, 8)
      : post.authorId;
  return 'Athlete $suffix';
}

String _formatDate(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
  if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
  return 'منذ ${difference.inDays} يوم';
}
