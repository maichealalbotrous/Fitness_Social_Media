import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/widgets/auth_theme.dart';

class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    required this.isObscured,
    required this.onPressed,
    super.key,
  });

  final bool isObscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isObscured ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
      icon: Icon(
        isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AuthTheme.textMuted,
      ),
    );
  }
}
