import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:flutter/material.dart';

class WorkoutLabel extends StatelessWidget {
  const WorkoutLabel(this.text, {this.color = WorkoutTheme.muted, super.key});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.5,
      ),
    );
  }
}
