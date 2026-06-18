import 'package:fitness_social_app/features/user/presentation/components/run/run_theme.dart';
import 'package:flutter/material.dart';

class RunLabel extends StatelessWidget {
  const RunLabel(this.text, {this.color = RunTheme.muted, super.key});

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
        letterSpacing: 2.2,
      ),
    );
  }
}
