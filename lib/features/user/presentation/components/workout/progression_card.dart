import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_label.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:flutter/material.dart';

class ProgressionCard extends StatelessWidget {
  const ProgressionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              WorkoutLabel('1RM PROGRESSION'),
              Spacer(),
              Text(
                'TOP 3 LIFTS',
                style: TextStyle(
                  color: WorkoutTheme.lime,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          _LiftProgress(
            name: 'Conventional Deadlift',
            weight: '210 KG',
            progress: 0.86,
            gain: '+5 KG',
          ),
          SizedBox(height: 18),
          _LiftProgress(
            name: 'Back Squat',
            weight: '165 KG',
            progress: 0.66,
            gain: '+5 KG',
          ),
          SizedBox(height: 18),
          _LiftProgress(name: 'Bench Press', weight: '125 KG', progress: 0.48),
          SizedBox(height: 26),
          Divider(color: WorkoutTheme.border),
          SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _StrengthBox(label: 'TOTAL PRS', value: '48'),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _StrengthBox(label: 'MAX LOAD', value: '210 KG'),
              ),
            ],
          ),
          SizedBox(height: 26),
          WorkoutLabel('MILESTONES'),
          SizedBox(height: 14),
          _Milestone(name: 'Deadlift', weight: '210kg', date: '2 DAYS AGO'),
          SizedBox(height: 12),
          _Milestone(name: 'Back Squat', weight: '165kg', date: '1 WEEK AGO'),
        ],
      ),
    );
  }
}

class _LiftProgress extends StatelessWidget {
  const _LiftProgress({
    required this.name,
    required this.weight,
    required this.progress,
    this.gain,
  });

  final String name;
  final String weight;
  final double progress;
  final String? gain;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              weight,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            if (gain != null)
              Text(
                gain!,
                style: const TextStyle(
                  color: WorkoutTheme.lime,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: const Color(0xFF1B1C1B),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.5 ? WorkoutTheme.lime : WorkoutTheme.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthBox extends StatelessWidget {
  const _StrengthBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WorkoutTheme.panelDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkoutLabel(label),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Milestone extends StatelessWidget {
  const _Milestone({
    required this.name,
    required this.weight,
    required this.date,
  });

  final String name;
  final String weight;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WorkoutTheme.panelDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 4, backgroundColor: WorkoutTheme.lime),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                weight,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(color: WorkoutTheme.muted, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
