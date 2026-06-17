import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:flutter/material.dart';

class NewPrBadge extends StatelessWidget {
  const NewPrBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FeedTheme.lime,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'NEW PR',
        style: TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: FeedTheme.lime.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'VERIFIED',
        style: TextStyle(
          color: FeedTheme.lime,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
