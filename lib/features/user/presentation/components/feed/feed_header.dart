import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:flutter/material.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FEED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            height: 0.95,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'PROGRESS · NOT ENTERTAINMENT',
          style: TextStyle(
            color: FeedTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: 22),
        // تبويبات الفلترة في أعلى صفحة الفيد.
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FeedTab(label: 'ALL', active: true),
              _FeedTab(label: 'PRS'),
              _FeedTab(label: 'WORKOUTS'),
              _FeedTab(label: 'RUNS'),
              _FeedTab(label: 'FOLLOWING'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: FeedTheme.border),
      ],
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: active ? 15 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: active ? FeedTheme.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : FeedTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
