import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/auth_dependencies.dart';
import 'package:fitness_social_app/features/auth/presentation/controllers/account_recovery_controller.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_action_layout.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_status_message.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_text_field.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  late final AccountRecoveryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthDependencies.createRecoveryController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AuthActionLayout(
          title: 'Verify your email',
          subtitle: 'Enter the verification code you received to enable account access.',
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
                  controller: _tokenController,
                  label: 'Verification code',
                  icon: Icons.mark_email_read_outlined,
                  textInputAction: TextInputAction.done,
                  validator: _validateToken,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'Confirm email address',
                  isLoading: _controller.isSubmitting,
                  onPressed: _submit,
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

    await _controller.verifyEmail(_tokenController.text.trim());
  }

  String? _validateToken(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Enter the verification code.';
    }
    return null;
  }
}
