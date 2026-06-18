import 'package:fitness_social_app/features/user/presentation/components/run/run_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/run/shared/run_avatar.dart';
import 'package:fitness_social_app/features/user/presentation/components/run/shared/run_label.dart';
import 'package:flutter/material.dart';

class RunPostCard extends StatelessWidget {
  const RunPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RunTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RunTheme.border),
      ),
      child: const Column(
        children: [_RunPostHeader(), _RunMapPreview(), _RunPostActions()],
      ),
    );
  }
}

class _RunPostHeader extends StatelessWidget {
  const _RunPostHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: RunTheme.panel,
      child: const Row(
        children: [
          RunAvatar(size: 42),
          SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marcus Thorne',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Today · Easy Recovery',
                style: TextStyle(color: RunTheme.muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RunMapPreview extends StatelessWidget {
  const _RunMapPreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.38,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RunMapPainter())),
          const Positioned(
            left: 14,
            bottom: 14,
            child: Row(
              children: [
                _MapMetric(label: 'DISTANCE', value: '5.0 KM'),
                SizedBox(width: 10),
                _MapMetric(label: 'PACE', value: '5:22 /KM'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunPostActions extends StatelessWidget {
  const _RunPostActions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Row(
        children: [
          Icon(Icons.favorite_border, color: RunTheme.muted, size: 25),
          SizedBox(width: 6),
          Text('0', style: TextStyle(color: RunTheme.muted, fontSize: 14)),
          SizedBox(width: 25),
          Icon(Icons.mode_comment_outlined, color: RunTheme.muted, size: 24),
          SizedBox(width: 6),
          Text('0', style: TextStyle(color: RunTheme.muted, fontSize: 14)),
          SizedBox(width: 25),
          Icon(Icons.near_me_outlined, color: RunTheme.muted, size: 24),
        ],
      ),
    );
  }
}

class _MapMetric extends StatelessWidget {
  const _MapMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RunTheme.panel.withValues(alpha: 0.92),
        border: Border.all(color: RunTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RunLabel(label),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    final streetPaint = Paint()
      ..color = const Color(0xFF101421)
      ..strokeWidth = 1.2;

    for (var i = 0; i < 12; i++) {
      final x = size.width * i / 11;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streetPaint);
    }
    for (var i = 0; i < 8; i++) {
      final y = size.height * i / 7;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), streetPaint);
    }

    final sideRoadPaint = Paint()
      ..color = const Color(0xFF11151D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final sidePath = Path()
      ..moveTo(0, size.height * 0.42)
      ..lineTo(size.width * 0.25, size.height * 0.30)
      ..lineTo(size.width * 0.55, size.height * 0.38)
      ..lineTo(size.width, size.height * 0.18);
    canvas.drawPath(sidePath, sideRoadPaint);

    final routeGlow = Paint()
      ..color = RunTheme.lime.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final route = Path()
      ..moveTo(size.width * 0.40, size.height * 0.78)
      ..cubicTo(
        size.width * 0.50,
        size.height * 0.68,
        size.width * 0.62,
        size.height * 0.66,
        size.width * 0.74,
        size.height * 0.66,
      )
      ..cubicTo(
        size.width * 0.84,
        size.height * 0.66,
        size.width * 0.94,
        size.height * 0.66,
        size.width,
        size.height * 0.64,
      )
      ..moveTo(size.width * 0.47, size.height * 0.72)
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.61,
        size.width * 0.46,
        size.height * 0.49,
        size.width * 0.52,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.38,
        size.width * 0.57,
        size.height * 0.38,
        size.width * 0.60,
        size.height * 0.37,
      );

    canvas.drawPath(route, routeGlow);
    canvas.drawPath(
      route,
      Paint()
        ..color = RunTheme.lime
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(
      Offset(size.width * 0.47, size.height * 0.72),
      5,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.47, size.height * 0.72),
      5,
      Paint()
        ..color = RunTheme.lime
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
