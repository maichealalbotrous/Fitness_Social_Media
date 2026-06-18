import 'package:fitness_social_app/features/user/presentation/components/run/run_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/run/shared/run_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/run/shared/run_label.dart';
import 'package:flutter/material.dart';

class RunStatsGrid extends StatelessWidget {
  const RunStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _RunStatCard(label: 'THIS WEEK', value: '22.4', unit: 'KM'),
        _RunStatCard(label: 'AVG PACE', value: '5:08', unit: '/ KM'),
        _RunStatCard(label: 'RUNS', value: '04', unit: 'SESSIONS'),
        _RunStatCard(label: 'STREAK', value: '03', unit: 'WEEKS', accent: true),
      ],
    );
  }
}

class _RunStatCard extends StatelessWidget {
  const _RunStatCard({
    required this.label,
    required this.value,
    required this.unit,
    this.accent = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 48) / 2;

    return SizedBox(
      width: width.clamp(150, 220),
      child: RunCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RunLabel(label),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: accent ? RunTheme.lime : Colors.white,
                fontSize: 24,
                height: 0.95,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              unit,
              style: const TextStyle(
                color: RunTheme.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
