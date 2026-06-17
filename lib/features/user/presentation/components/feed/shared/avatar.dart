import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:flutter/material.dart';

class FeedAvatar extends StatelessWidget {
  const FeedAvatar({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF151515),
        border: Border.all(color: FeedTheme.border),
      ),
      child: Icon(Icons.person, color: FeedTheme.muted, size: size * 0.56),
    );
  }
}
