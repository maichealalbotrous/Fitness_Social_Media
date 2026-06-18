import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_label.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:flutter/material.dart';

class LogWorkoutCard extends StatelessWidget {
  const LogWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutCard(
      borderColor: WorkoutTheme.lime.withValues(alpha: 0.25),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOG WORKOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                WorkoutLabel('SELECT A TEMPLATE OR START FROM SCRATCH'),
                SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _WorkoutAction(
                        icon: Icons.play_arrow,
                        label: 'EMPTY WORKOUT',
                        active: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _WorkoutAction(
                        icon: Icons.history,
                        label: 'USE TEMPLATE',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: WorkoutTheme.border),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Row(
              children: [
                WorkoutLabel('QUICK ACTIONS'),
                Spacer(),
                Text(
                  'Manage Templates ->',
                  style: TextStyle(
                    color: WorkoutTheme.lime,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutAction extends StatelessWidget {
  const _WorkoutAction({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF121807) : WorkoutTheme.panelDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? WorkoutTheme.lime.withValues(alpha: 0.25)
              : WorkoutTheme.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: active
                ? WorkoutTheme.lime.withValues(alpha: 0.25)
                : const Color(0xFF191A19),
            child: Icon(
              icon,
              color: active ? WorkoutTheme.lime : WorkoutTheme.muted,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
