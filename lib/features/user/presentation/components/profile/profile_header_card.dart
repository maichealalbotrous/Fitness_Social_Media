import 'package:fitness_social_app/features/user/presentation/components/profile/profile_theme.dart';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ProfileCover(),
            Transform.translate(
              offset: const Offset(0, -56),
              child: const _ProfileInfo(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3.15,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF222A08), Color(0xFF141806), Color(0xFF030403)],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ProfileAvatar(),
              Spacer(),
              _CircleAction(icon: Icons.share_outlined),
              SizedBox(width: 10),
              _CircleAction(icon: Icons.settings_outlined),
              SizedBox(width: 12),
              _EditProfileButton(),
            ],
          ),
          const SizedBox(height: 36),
          const Text(
            'Marcus Thorne',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
              height: 0.95,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '@m_thorne_lifts',
            style: TextStyle(color: ProfileTheme.muted, fontSize: 15),
          ),
          const SizedBox(height: 20),
          const Text(
            'Powerbuilding. 4x per week. PPL split. Building a high-performance engine\nthrough data-driven training. Focused on the long game. 🏋️💪',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _MetaItem(
                icon: Icons.location_on_outlined,
                text: 'Berlin, Germany',
              ),
              _MetaItem(
                icon: Icons.link,
                text: 'repflow.com/m_thorne',
                accent: true,
              ),
              _MetaItem(
                icon: Icons.calendar_today_outlined,
                text: 'Joined June 2024',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              _FollowMetric(value: '1.2k', label: 'Followers'),
              SizedBox(width: 28),
              _FollowMetric(value: '428', label: 'Following'),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(color: ProfileTheme.border),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 124,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(color: ProfileTheme.background, width: 5),
      ),
      child: ClipOval(child: CustomPaint(painter: _AvatarPainter())),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ProfileTheme.panel,
        border: Border.all(color: ProfileTheme.border),
      ),
      child: Icon(icon, color: ProfileTheme.muted, size: 20),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: () {},
        child: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.text,
    this.accent = false,
  });

  final IconData icon;
  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: ProfileTheme.muted, size: 17),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: accent ? ProfileTheme.lime : ProfileTheme.muted,
            fontSize: 13,
            fontWeight: accent ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FollowMetric extends StatelessWidget {
  const _FollowMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: const TextStyle(
              color: ProfileTheme.muted,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    final bg = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.18),
        radius: 0.95,
        colors: [Color(0xFF242424), Colors.black],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final body = Paint()
      ..color = const Color(0xFFBFC0C2).withValues(alpha: 0.18);
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.75);

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.30,
        size.height * 0.35,
        size.width * 0.40,
        size.height * 0.50,
      ),
      body,
    );
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.30),
      size.width * 0.13,
      body,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.44,
        size.width * 0.10,
        size.height * 0.28,
      ),
      shadow,
    );

    final barPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.62),
      Offset(size.width * 0.88, size.height * 0.62),
      barPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.62),
      size.width * 0.15,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.white.withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
