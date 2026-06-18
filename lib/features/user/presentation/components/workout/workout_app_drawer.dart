import 'package:fitness_social_app/features/user/presentation/components/workout/workout_theme.dart';
import 'package:fitness_social_app/features/user/presentation/pages/feed_page.dart';
import 'package:flutter/material.dart';

class WorkoutAppDrawer extends StatelessWidget {
  const WorkoutAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: WorkoutTheme.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DrawerLogo(),
              const SizedBox(height: 42),
              _DrawerItem(
                icon: Icons.home_outlined,
                label: 'Feed',
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedPage()),
                ),
              ),
              const _DrawerItem(
                icon: Icons.fitness_center,
                label: 'Workouts',
                active: true,
              ),
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
                    backgroundColor: WorkoutTheme.lime,
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? Colors.white : WorkoutTheme.muted,
              size: 27,
            ),
            const SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : WorkoutTheme.muted,
                fontSize: 18,
                fontWeight: active ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ],
        ),
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
              color: WorkoutTheme.lime,
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
        CircleAvatar(
          radius: 21,
          backgroundColor: Color(0xFF151515),
          child: Icon(Icons.person, color: WorkoutTheme.muted),
        ),
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
                style: TextStyle(color: WorkoutTheme.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Icon(Icons.more_horiz, color: WorkoutTheme.muted),
      ],
    );
  }
}
