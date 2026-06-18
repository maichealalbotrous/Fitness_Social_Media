import 'dart:math' as math;

import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_card.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/shared/workout_label.dart';
import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:flutter/material.dart';

class VolumeIntensityCard extends StatelessWidget {
  const VolumeIntensityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Text(
                'VOLUME INTENSITY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              WorkoutLabel('LAST 7 DAYS (KG)'),
            ],
          ),
          SizedBox(height: 24),
          _VolumeBars(),
        ],
      ),
    );
  }
}

class _VolumeBars extends StatelessWidget {
  const _VolumeBars();

  static const values = [0.48, 0.58, 0.0, 0.82, 0.45, 0.88, 0.25];
  static const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ChartGridPainter())),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: math.max(values[i], 0.02),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 36,
                            decoration: BoxDecoration(
                              color: i == 1 || i == 3 || i == 5
                                  ? WorkoutTheme.lime
                                  : WorkoutTheme.olive,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels[i],
                        style: const TextStyle(
                          color: WorkoutTheme.muted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class MuscleFrequencyCard extends StatelessWidget {
  const MuscleFrequencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Text(
                'MUSCLE FREQUENCY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              WorkoutLabel('TIMES PLAYED / MONTH'),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: _FrequencyPainter(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '62',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'MUSCLE HITS',
                        style: TextStyle(
                          color: WorkoutTheme.muted,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WorkoutTheme.border
      ..strokeWidth = 1;

    for (var i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FrequencyPainter extends CustomPainter {
  const _FrequencyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width * 0.42);
    const stroke = 15.0;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFF252725);
    final limePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = WorkoutTheme.lime;
    final olivePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = WorkoutTheme.olive;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, basePaint);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 0.55, false, limePaint);
    canvas.drawArc(rect, math.pi * 0.15, math.pi * 0.35, false, olivePaint);
    canvas.drawArc(rect, math.pi * 0.62, math.pi * 0.42, false, olivePaint);

    final inner = Rect.fromCircle(center: center, radius: size.width * 0.27);
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = WorkoutTheme.muted;
    canvas.drawArc(inner, -math.pi / 2, math.pi * 1.65, false, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
