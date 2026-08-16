import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/feed_badges.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/post_widgets.dart';
import 'package:flutter/material.dart';

class PrPostCard extends StatelessWidget {
  const PrPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PostShell(
      borderColor: FeedTheme.lime.withValues(alpha: 0.35),
      child: Column(
        children: const [
          PostHeader(
            name: 'Repflow athlete',
            subtitle: '2 hours ago',
            action: NewPrBadge(),
          ),
          _PrBody(),
          PostActions(),
        ],
      ),
    );
  }
}

class _PrBody extends StatelessWidget {
  const _PrBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF151A08), Color(0xFF0A0B08)],
        ),
      ),
      // جسم المنشور يعرض الرقم الشخصي الجديد كما في صورة post.png.
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '140 KG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 0.9,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          SizedBox(width: 86, child: Divider(color: FeedTheme.lime, height: 2)),
          SizedBox(height: 8),
          Text(
            'OVERHEAD PRESS',
            style: TextStyle(
              color: FeedTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
        ],
      ),
    );
  }
}
