import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:flutter/material.dart';

class FeedMobileNavigation extends StatelessWidget {
  const FeedMobileNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 68,
      backgroundColor: FeedTheme.panelDark,
      indicatorColor: FeedTheme.lime.withValues(alpha: 0.16),
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Feed'),
        NavigationDestination(
          icon: Icon(Icons.fitness_center),
          label: 'Workout',
        ),
        NavigationDestination(
          icon: Icon(Icons.monitor_heart_outlined),
          label: 'Runs',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
