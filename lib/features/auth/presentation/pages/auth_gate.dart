import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/auth_dependencies.dart';
import 'package:fitness_social_app/features/auth/presentation/pages/auth_page.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_theme.dart';
import 'package:fitness_social_app/features/user/presentation/pages/feed_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _hasActiveSession;

  @override
  void initState() {
    super.initState();
    _hasActiveSession = AuthDependencies.createHasActiveSession()();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasActiveSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AuthLoadingPage();
        }

        return snapshot.data == true ? const FeedPage() : const AuthPage();
      },
    );
  }
}

class _AuthLoadingPage extends StatelessWidget {
  const _AuthLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AuthTheme.background,
      body: Center(
        child: CircularProgressIndicator(color: AuthTheme.lime),
      ),
    );
  }
}
