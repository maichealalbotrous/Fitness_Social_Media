import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/avatar.dart';
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
    super.key,
  });

  final String name;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: FeedTheme.panel,
      child: Row(
        children: [
          const FeedAvatar(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: FeedTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class PostActions extends StatelessWidget {
  const PostActions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Row(
        children: [
          Icon(Icons.favorite_border, color: FeedTheme.muted, size: 26),
          SizedBox(width: 24),
          Icon(Icons.mode_comment_outlined, color: FeedTheme.muted, size: 25),
          SizedBox(width: 6),
          Text('0', style: TextStyle(color: FeedTheme.muted, fontSize: 14)),
          SizedBox(width: 24),
          Icon(Icons.near_me_outlined, color: FeedTheme.muted, size: 25),
        ],
      ),
    );
  }
}
