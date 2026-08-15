class AuthValidators {
  const AuthValidators._();

  static String? username(String? value) {
    final username = value?.trim() ?? '';
    if (username.length < 3 || username.length > 20) {
      return 'يجب أن يكون اسم المستخدم بين 3 و20 حرفاً.';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) {
      return 'أدخل بريداً إلكترونياً صالحاً.';
    }
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').length < 6) {
      return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';
    }
    return null;
  }

  static String? passwordConfirmation({
    required String password,
    required String? confirmation,
  }) {
    if (confirmation != password) {
      return 'كلمتا المرور غير متطابقتين.';
    }
    return null;
  }
}
