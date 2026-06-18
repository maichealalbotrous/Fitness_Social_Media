import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_label.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:flutter/material.dart';

class TrainingConsistencyCard extends StatelessWidget {
  const TrainingConsistencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'GYM CONSISTENCY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          WorkoutLabel('TRAINING FREQUENCY OVER THE PAST YEAR'),
          SizedBox(height: 18),
          _ConsistencyHeatMap(),
          SizedBox(height: 16),
          Row(
            children: [
              Text(
                '14 TOTAL SESSIONS',
                style: TextStyle(
                  color: WorkoutTheme.muted,
                  fontSize: 10,
                  letterSpacing: 1.8,
                ),
              ),
              Spacer(),
              Text(
                'STREAK: 12 DAYS',
                style: TextStyle(
                  color: WorkoutTheme.muted,
                  fontSize: 10,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsistencyHeatMap extends StatelessWidget {
  const _ConsistencyHeatMap();

  static const activeDays = {
    82,
    86,
    91,
    95,
    98,
    101,
    107,
    111,
    116,
    120,
    121,
    122,
    123,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jun', style: _monthStyle),
            Text('Aug', style: _monthStyle),
            Text('Oct', style: _monthStyle),
            Text('Dec', style: _monthStyle),
            Text("Jan '26", style: _monthStyle),
            Text('Mar', style: _monthStyle),
            Text('May', style: _monthStyle),
            Text('Jun', style: _monthStyle),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 92,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 24,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: 120,
            itemBuilder: (context, index) {
              final isActive = activeDays.contains(index);
              return DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? WorkoutTheme.lime : const Color(0xFF171817),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

const _monthStyle = TextStyle(color: WorkoutTheme.muted, fontSize: 9);
