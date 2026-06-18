import 'package:fitness_social_app/features/user/presentation/components/profile/profile_theme.dart';
import 'package:fitness_social_app/features/user/presentation/pages/feed_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/run_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/workout_page.dart';
import 'package:flutter/material.dart';

class ProfileMobileNavigation extends StatelessWidget {
  const ProfileMobileNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 68,
      backgroundColor: ProfileTheme.panelDark,
      indicatorColor: ProfileTheme.lime.withValues(alpha: 0.16),
      selectedIndex: 3,
      onDestinationSelected: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FeedPage()),
          );
        }
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutPage()),
          );
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RunPage()),
          );
        }
      },
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
