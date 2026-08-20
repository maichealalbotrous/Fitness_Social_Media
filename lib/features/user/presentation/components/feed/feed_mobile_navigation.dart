import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';
import 'package:fitness_social_app/features/user/presentation/pages/profile_page.dart';
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
      onDestinationSelected: (index) {
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Feed'),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
