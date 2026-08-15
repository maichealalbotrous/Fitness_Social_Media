import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/auth_dependencies.dart';
import 'package:fitness_social_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_layout.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthDependencies.createController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AuthLayout(
          controller: _controller,
          onAuthenticated: _openFeed,
        );
      },
    );
  }

  void _openFeed() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.feed,
      (route) => false,
    );
  }
}
