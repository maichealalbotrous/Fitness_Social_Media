import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/feed_badges.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/info_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/section_label.dart';
import 'package:flutter/material.dart';

class IdentityCard extends StatelessWidget {
  const IdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(children: [SectionLabel('IDENTITY'), Spacer(), VerifiedBadge()]),
          SizedBox(height: 20),
          _LiftMetric(label: 'BENCH PRESS', value: '125', unit: 'KG'),
          SizedBox(height: 18),
          _LiftMetric(label: 'BACK SQUAT', value: '160', unit: 'KG'),
          SizedBox(height: 18),
          _LiftMetric(label: 'DEADLIFT', value: '210', unit: 'KG'),
          SizedBox(height: 24),
          Divider(color: FeedTheme.border),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BottomMetric(
                  label: 'STREAK',
                  value: '12 DAYS',
                  accent: true,
                ),
              ),
              Expanded(
                child: _BottomMetric(label: 'VOL/WK', value: '42,5T'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiftMetric extends StatelessWidget {
  const _LiftMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomMetric extends StatelessWidget {
  const _BottomMetric({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: accent ? FeedTheme.lime : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
