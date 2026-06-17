import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/section_label.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/post_widgets.dart';
import 'package:flutter/material.dart';

class ActivityPostCard extends StatelessWidget {
  const ActivityPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PostShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          PostHeader(
            name: 'Sarah Jenkins',
            subtitle: '4 hours ago · Late Night Push',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 22, 18, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SmallStatCard(label: 'VOLUME', value: '8,420 KG'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _SmallStatCard(label: 'DURATION', value: '1H 12M'),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                _ExerciseRow(name: 'Bench Press', details: '5 x 5 @ 100kg'),
                _ExerciseRow(name: 'Incline DB Press', details: '4 x 8 @ 34kg'),
                _ExerciseRow(name: 'Cable Fly', details: '3 x 12'),
              ],
            ),
          ),
          PostActions(),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FeedTheme.panelDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.name, required this.details});

  final String name;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            details,
            style: const TextStyle(
              color: FeedTheme.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
