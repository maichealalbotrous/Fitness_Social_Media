import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/shared/avatar.dart';
import 'package:flutter/material.dart';

class FeedAppDrawer extends StatelessWidget {
  const FeedAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: FeedTheme.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DrawerLogo(),
              const SizedBox(height: 42),
              // الصورة: side_bar.png لكن هنا كـ Drawer مناسب للموبايل.
              const _DrawerItem(
                icon: Icons.home_outlined,
                label: 'Feed',
                active: true,
              ),
              const _DrawerItem(icon: Icons.fitness_center, label: 'Workouts'),
              const _DrawerItem(
                icon: Icons.monitor_heart_outlined,
                label: 'Runs',
              ),
              const _DrawerItem(icon: Icons.person_outline, label: 'Profile'),
              const _DrawerItem(icon: Icons.search, label: 'Search'),
              const _DrawerItem(
                icon: Icons.notifications_none,
                label: 'Notifications',
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: FeedTheme.lime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Log Workout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const Spacer(),
              const _CurrentUserTile(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Row(
        children: [
          Icon(icon, color: active ? Colors.white : FeedTheme.muted, size: 27),
          const SizedBox(width: 18),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : FeedTheme.muted,
              fontSize: 18,
              fontWeight: active ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerLogo extends StatelessWidget {
  const _DrawerLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'REP',
            style: TextStyle(
              color: FeedTheme.lime,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: 'FLOW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentUserTile extends StatelessWidget {
  const _CurrentUserTile();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        FeedAvatar(size: 42),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Michel Jarjoura',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '@Michel jarjoura',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: FeedTheme.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Icon(Icons.more_horiz, color: FeedTheme.muted),
      ],
    );
  }
}
