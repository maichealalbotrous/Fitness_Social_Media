import 'package:fitness_social_app/features/user/presentation/components/run/run_theme.dart';
import 'package:flutter/material.dart';

class RunHeader extends StatelessWidget {
  const RunHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RUNS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Lightweight GPS tracking. No segments. No rankings.',
                    style: TextStyle(color: RunTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              height: 42,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: RunTheme.lime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'START RUN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Divider(height: 1, color: RunTheme.border),
      ],
    );
  }
}
