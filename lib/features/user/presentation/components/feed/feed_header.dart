import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:flutter/material.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({
    this.onCreate,
    this.onAll,
    this.onFollowing,
    this.followingOnly = false,
    super.key,
  });

  final VoidCallback? onCreate;
  final VoidCallback? onAll;
  final VoidCallback? onFollowing;
  final bool followingOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Text(
                'FEED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (onCreate != null)
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('POST'),
                style: FilledButton.styleFrom(
                  backgroundColor: FeedTheme.lime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
          ],
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FeedTab(label: 'ALL', active: !followingOnly, onTap: onAll),
              const _FeedTab(label: 'PRS'),
              const _FeedTab(label: 'WORKOUTS'),
              const _FeedTab(label: 'RUNS'),
              _FeedTab(
                label: 'FOLLOWING',
                active: followingOnly,
                onTap: onFollowing,
              ),
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
  const _FeedTab({
    required this.label,
    this.active = false,
    this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
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
      ),
    );
  }
}
