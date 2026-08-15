import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/widgets/auth_theme.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(color: AuthTheme.textPrimary),
      cursorColor: AuthTheme.lime,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AuthTheme.textMuted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AuthTheme.fieldSurface,
        labelStyle: const TextStyle(color: AuthTheme.textMuted),
        hintStyle: const TextStyle(color: AuthTheme.textMuted),
        errorStyle: const TextStyle(color: AuthTheme.error),
        border: _border(AuthTheme.border),
        enabledBorder: _border(AuthTheme.border),
        focusedBorder: _border(AuthTheme.lime),
        errorBorder: _border(AuthTheme.error),
        focusedErrorBorder: _border(AuthTheme.error),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }
}
