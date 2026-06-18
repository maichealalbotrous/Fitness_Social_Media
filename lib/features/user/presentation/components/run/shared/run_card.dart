import 'package:fitness_social_app/features/user/presentation/components/run/run_theme.dart';
import 'package:flutter/material.dart';

class RunCard extends StatelessWidget {
  const RunCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor = RunTheme.border,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: RunTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
