import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_label.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:flutter/material.dart';

class LogPrCard extends StatelessWidget {
  const LogPrCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutCard(
      borderColor: WorkoutTheme.lime.withValues(alpha: 0.18),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    WorkoutLabel('ACHIEVEMENT', color: WorkoutTheme.lime),
                    Spacer(),
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Color(0xFF1C2606),
                      child: Icon(
                        Icons.emoji_events_outlined,
                        color: WorkoutTheme.lime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'LOG NEW PR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 26),
                const WorkoutLabel('SELECT MOVEMENT'),
                const SizedBox(height: 8),
                const _InputBox(text: 'Back Squat', icon: Icons.expand_more),
                const SizedBox(height: 16),
                const WorkoutLabel('LOAD AMOUNT (KG)'),
                const SizedBox(height: 8),
                const _InputBox(
                  text: '000                         KG',
                  dim: true,
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: WorkoutTheme.lime,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'VERIFY & RECORD PERFORMANCE  ↗',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            color: const Color(0xFF101508),
            child: const Text(
              'ALL PRS ARE ADDED TO YOUR GLOBAL IDENTITY AND VERIFIED BY TRAINING VOLUME.',
              style: TextStyle(
                color: WorkoutTheme.muted,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.text, this.icon, this.dim = false});

  final String text;
  final IconData? icon;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: WorkoutTheme.panelDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WorkoutTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: dim ? const Color(0xFF1B1D1B) : Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (icon != null) Icon(icon, color: WorkoutTheme.muted, size: 20),
        ],
      ),
    );
  }
}
