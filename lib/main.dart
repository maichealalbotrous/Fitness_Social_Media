import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'package:fitness_social_app/features/user/presentation/pages/feed_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/profile_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/run_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/workout_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessSocialApp());
}

class FitnessSocialApp extends StatelessWidget {
  const FitnessSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repflow',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF030403),
        fontFamily: 'Arial',
      ),
      initialRoute: AppRoutes.feed,
      routes: {
        AppRoutes.feed: (_) => const FeedPage(),
        AppRoutes.workouts: (_) => const WorkoutPage(),
        AppRoutes.runs: (_) => const RunPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
      },
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
