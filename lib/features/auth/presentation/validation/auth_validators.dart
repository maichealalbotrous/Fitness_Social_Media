class AuthValidators {
  const AuthValidators._();

  static String? username(String? value) {
    final username = value?.trim() ?? '';
    if (username.length < 3 || username.length > 20) {
      return 'Username must be between 3 and 20 characters.';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  static String? passwordConfirmation({
    required String password,
    required String? confirmation,
  }) {
    if (confirmation != password) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
