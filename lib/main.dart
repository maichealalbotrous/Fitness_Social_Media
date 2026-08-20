import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/pages/auth_page.dart';
import 'package:fitness_social_app/features/auth/presentation/pages/auth_gate.dart';
import 'package:fitness_social_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:fitness_social_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:fitness_social_app/features/auth/presentation/pages/verify_email_page.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'package:fitness_social_app/features/user/presentation/pages/feed_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/profile_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/user_search_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/run_page.dart';
import 'package:fitness_social_app/features/user/presentation/pages/workout_page.dart';
import 'package:fitness_social_app/features/community/presentation/pages/community_page.dart';
import 'package:fitness_social_app/features/community/presentation/pages/my_communities_page.dart';
import 'package:fitness_social_app/features/challenges/presentation/pages/challenges_page.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_page.dart';
import 'package:fitness_social_app/features/coach/presentation/my_coaches_page.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_dependencies.dart';
import 'package:fitness_social_app/features/exercises/presentation/exercises_page.dart';
import 'package:fitness_social_app/features/exercises/presentation/exercise_dependencies.dart';
import 'package:fitness_social_app/features/physical_data/presentation/physical_data_page.dart';
import 'package:fitness_social_app/features/physical_data/presentation/physical_data_dependencies.dart';
import 'package:fitness_social_app/features/user_sessions/presentation/user_sessions_page.dart';
import 'package:fitness_social_app/features/user_sessions/presentation/user_session_dependencies.dart';
import 'package:fitness_social_app/features/workout_planning/presentation/workout_planning_page.dart';
import 'package:fitness_social_app/features/workout_planning/presentation/workout_planning_dependencies.dart';

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030403),
        colorSchemeSeed: const Color(0xFFB7FF00),
        fontFamily: 'Arial',
      ),
      home: AuthGate(),
      routes: {
        AppRoutes.auth: (_) => const AuthPage(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
        AppRoutes.resetPassword: (_) => const ResetPasswordPage(),
        AppRoutes.verifyEmail: (_) => const VerifyEmailPage(),
        AppRoutes.feed: (_) => const FeedPage(),
        AppRoutes.workouts: (_) => const WorkoutPage(),
        AppRoutes.runs: (_) => const RunPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
        AppRoutes.community: (_) => const CommunityPage(),
        AppRoutes.myCommunities: (_) => const MyCommunitiesPage(),
        AppRoutes.userSearch: (_) => const UserSearchPage(),
        AppRoutes.challenges: (_) => const ChallengesPage(),
        AppRoutes.coach: (_) => CoachPage(controller: CoachDependencies.createController()),
        AppRoutes.myCoaches: (_) => MyCoachesPage(controller: CoachDependencies.createController()),
        AppRoutes.exercises: (_) => ExercisesPage(controller: ExerciseDependencies.createController()),
        AppRoutes.physicalData: (_) => PhysicalDataPage(controller: PhysicalDataDependencies.createController()),
        AppRoutes.userSessions: (_) => UserSessionsPage(controller: UserSessionDependencies.createController()),
        AppRoutes.workoutPlanning: (_) => WorkoutPlanningPage(controller: WorkoutPlanningDependencies.createController()),
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
