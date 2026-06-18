import 'package:fitness_social_app/features/user/presentation/components/run/run_theme.dart';
import 'package:flutter/material.dart';

class RunAvatar extends StatelessWidget {
  const RunAvatar({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF151515),
        border: Border.all(color: RunTheme.border),
      ),
      child: Icon(Icons.person, color: RunTheme.muted, size: size * 0.56),
    );
  }
}
