import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/auth_dependencies.dart';
import 'package:fitness_social_app/features/auth/presentation/controllers/account_recovery_controller.dart';
import 'package:fitness_social_app/features/auth/presentation/validation/auth_validators.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_action_layout.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_status_message.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/password_visibility_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  late final AccountRecoveryController _controller;

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    _controller = AuthDependencies.createRecoveryController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AuthActionLayout(
          title: 'تعيين كلمة مرور جديدة',
          subtitle: 'أدخل رمز الاستعادة وكلمة المرور الجديدة لإكمال العملية.',
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
                  label: 'رمز الاستعادة',
                  icon: Icons.key_outlined,
                  textInputAction: TextInputAction.next,
                  validator: _validateToken,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور الجديدة',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.password,
                  suffixIcon: PasswordVisibilityButton(
                    isObscured: _obscurePassword,
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _confirmationController,
                  label: 'تأكيد كلمة المرور الجديدة',
                  icon: Icons.lock_reset_outlined,
                  obscureText: _obscureConfirmation,
                  textInputAction: TextInputAction.done,
                  validator: (value) => AuthValidators.passwordConfirmation(
                    password: _passwordController.text,
                    confirmation: value,
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: PasswordVisibilityButton(
                    isObscured: _obscureConfirmation,
                    onPressed: () {
                      setState(
                        () => _obscureConfirmation = !_obscureConfirmation,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'تحديث كلمة المرور',
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

    await _controller.resetPassword(
      token: _tokenController.text.trim(),
      newPassword: _passwordController.text,
    );
  }

  String? _validateToken(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'أدخل رمز الاستعادة.';
    }
    return null;
  }
}
