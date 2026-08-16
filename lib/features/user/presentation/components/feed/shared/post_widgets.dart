import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/avatar.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/local_profile_avatar.dart';
import 'package:flutter/material.dart';

class PostShell extends StatelessWidget {
  const PostShell({
    required this.child,
    this.borderColor = FeedTheme.border,
    super.key,
  });

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FeedTheme.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({
    required this.name,
    required this.subtitle,
    this.action,
    this.avatarBase64,
    this.onTap,
    super.key,
  });

  final String name;
  final String subtitle;
  final Widget? action;
  final String? avatarBase64;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        color: FeedTheme.panel,
        child: Row(
        children: [
          avatarBase64 == null
              ? const FeedAvatar(size: 42)
              : LocalProfileAvatar(
                  radius: 21,
                  base64Image: avatarBase64,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: FeedTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          ?action,
        ],
        ),
      ),
    );
  }
}

class PostActions extends StatelessWidget {
  const PostActions({
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.onLike,
    this.onComment,
    super.key,
  });

  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Row(
        children: [
          _PostActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: likesCount.toString(),
            color: isLiked ? Colors.red : FeedTheme.muted,
            onPressed: onLike,
          ),
          const SizedBox(width: 24),
          _PostActionButton(
            icon: Icons.mode_comment_outlined,
            label: commentsCount.toString(),
            onPressed: onComment,
          ),
          const SizedBox(width: 24),
          const Icon(Icons.near_me_outlined, color: FeedTheme.muted, size: 25),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.icon,
    required this.label,
    this.color = FeedTheme.muted,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
