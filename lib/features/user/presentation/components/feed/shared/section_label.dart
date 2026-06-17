import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {this.color = FeedTheme.muted, super.key});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }
}
