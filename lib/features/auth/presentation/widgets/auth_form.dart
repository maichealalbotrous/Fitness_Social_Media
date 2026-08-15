import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fitness_social_app/features/auth/presentation/validation/auth_validators.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_status_message.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/password_visibility_button.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_theme.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    required this.controller,
    required this.onAuthenticated,
    super.key,
  });

  final AuthController controller;
  final VoidCallback onAuthenticated;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  bool get _isRegistering => widget.controller.mode == AuthMode.register;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = widget.controller.isSubmitting;
    final title = _isRegistering ? 'أنشئ حسابك' : 'مرحباً بعودتك';
    final subtitle = _isRegistering
        ? 'انضم إلى مجتمع Repflow الرياضي.'
        : 'سجّل الدخول لمتابعة تقدمك وتحدياتك.';

    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AuthTheme.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: AuthTheme.textMuted,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            if (widget.controller.errorMessage case final String message) ...[
              AuthStatusMessage(message: message, isError: true),
              const SizedBox(height: 16),
            ],
            if (widget.controller.successMessage case final String message) ...[
              AuthStatusMessage(message: message, isError: false),
              const SizedBox(height: 16),
            ],
            if (_isRegistering) ...[
              AuthTextField(
                controller: _usernameController,
                label: 'اسم المستخدم',
                hintText: 'مثال: michael_fit',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: AuthValidators.username,
              ),
              const SizedBox(height: 14),
            ],
            AuthTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hintText: 'name@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: _isRegistering
                  ? TextInputAction.next
                  : TextInputAction.done,
              autofillHints: [
                _isRegistering
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              suffixIcon: PasswordVisibilityButton(
                isObscured: _obscurePassword,
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: AuthValidators.password,
              onFieldSubmitted: (_) {
                if (!_isRegistering) {
                  _submit();
                }
              },
            ),
            if (!_isRegistering)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(context).pushNamed(
                            AppRoutes.forgotPassword,
                          ),
                  style: TextButton.styleFrom(foregroundColor: AuthTheme.lime),
                  child: const Text('هل نسيت كلمة المرور؟'),
                ),
              ),
            if (_isRegistering) ...[
              const SizedBox(height: 14),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                icon: Icons.lock_reset_outlined,
                obscureText: _obscureConfirmation,
                textInputAction: TextInputAction.done,
                suffixIcon: PasswordVisibilityButton(
                  isObscured: _obscureConfirmation,
                  onPressed: () {
                    setState(
                      () => _obscureConfirmation = !_obscureConfirmation,
                    );
                  },
                ),
                validator: (value) => AuthValidators.passwordConfirmation(
                  password: _passwordController.text,
                  confirmation: value,
                ),
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AuthTheme.lime,
                  disabledBackgroundColor: AuthTheme.lime.withValues(alpha: 0.45),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _isRegistering ? 'إنشاء الحساب' : 'تسجيل الدخول',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isRegistering ? 'لديك حساب بالفعل؟' : 'ليس لديك حساب؟',
                  style: const TextStyle(color: AuthTheme.textMuted),
                ),
                TextButton(
                  onPressed: isSubmitting ? null : _switchMode,
                  style: TextButton.styleFrom(foregroundColor: AuthTheme.lime),
                  child: Text(
                    _isRegistering ? 'سجّل الدخول' : 'أنشئ حساباً',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            if (!_isRegistering)
              Center(
                child: TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(context).pushNamed(
                            AppRoutes.verifyEmail,
                          ),
                  style: TextButton.styleFrom(foregroundColor: AuthTheme.lime),
                  child: const Text('لديك رمز التحقق؟ فعّل بريدك الإلكتروني'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final outcome = await widget.controller.submit(
      username: _isRegistering ? _usernameController.text.trim() : null,
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || outcome != AuthSubmissionOutcome.authenticated) {
      return;
    }

    widget.onAuthenticated();
  }

  void _switchMode() {
    widget.controller.switchMode();
    _formKey.currentState?.reset();
  }
}
