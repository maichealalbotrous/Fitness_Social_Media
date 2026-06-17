import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/info_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/section_label.dart';
import 'package:flutter/material.dart';

class WeeklyChallengeCard extends StatelessWidget {
  const WeeklyChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      background: FeedTheme.challenge,
      borderColor: FeedTheme.lime.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('WEEKLY CHALLENGE', color: FeedTheme.lime),
          const SizedBox(height: 22),
          const Text(
            'THE 50-TON CLUB',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lift 50,000kg cumulative volume this week.',
            style: TextStyle(color: FeedTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(
              value: 0.65,
              minHeight: 6,
              backgroundColor: Color(0xFF10130B),
              valueColor: AlwaysStoppedAnimation<Color>(FeedTheme.lime),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                '32.5T',
                style: TextStyle(color: FeedTheme.muted, fontSize: 11),
              ),
              Spacer(),
              Text(
                '50.0T',
                style: TextStyle(color: FeedTheme.muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
