import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/auth_dependencies.dart';
import 'package:fitness_social_app/features/auth/presentation/controllers/account_recovery_controller.dart';
import 'package:fitness_social_app/features/auth/presentation/validation/auth_validators.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_action_layout.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_status_message.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final AccountRecoveryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthDependencies.createRecoveryController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AuthActionLayout(
          title: 'Password recovery',
          subtitle: 'Enter your email to receive account recovery instructions.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_controller.errorMessage case final String message) ...[
                  AuthStatusMessage(message: message, isError: true),
                  const SizedBox(height: 16),
                ],
                if (_controller.successMessage case final String message) ...[
                  AuthStatusMessage(message: message, isError: false),
                  const SizedBox(height: 16),
                ],
                AuthTextField(
                  controller: _emailController,
                  label: 'Email address',
                  hintText: 'name@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  validator: AuthValidators.email,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'Send instructions',
                  isLoading: _controller.isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.resetPassword);
                  },
                  style: TextButton.styleFrom(foregroundColor: AuthTheme.lime),
                  child: const Text('Have a recovery code? Reset your password'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await _controller.requestPasswordReset(_emailController.text.trim());
  }
}
