import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_label.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:flutter/material.dart';

class PerformanceHeader extends StatelessWidget {
  const PerformanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERFORMANCE TRACKER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            height: 0.95,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'PRECISION TRAINING · DATA VERIFIED',
          style: TextStyle(
            color: WorkoutTheme.muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.2,
          ),
        ),
        const SizedBox(height: 22),
        // الارقام السريعة الموجودة في يمين الهيدر في تصميم الويب.
        const Row(
          children: [
            Expanded(
              child: _TrackerMetric(
                icon: Icons.calendar_today_outlined,
                label: 'CONSISTENCY',
                value: '92%',
              ),
            ),
            Expanded(
              child: _TrackerMetric(
                icon: Icons.trending_up,
                label: 'INTENSITY',
                value: '+4.2%',
                showDot: true,
              ),
            ),
            Expanded(
              child: _TrackerMetric(
                icon: Icons.bolt_outlined,
                label: 'RANK',
                value: 'A+',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(height: 1, color: WorkoutTheme.border),
      ],
    );
  }
}

class _TrackerMetric extends StatelessWidget {
  const _TrackerMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.showDot = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: WorkoutTheme.muted, size: 13),
            const SizedBox(width: 5),
            Flexible(child: WorkoutLabel(label)),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (showDot) ...[
              const SizedBox(width: 7),
              const CircleAvatar(radius: 3, backgroundColor: WorkoutTheme.lime),
            ],
          ],
        ),
      ],
    );
  }
}
