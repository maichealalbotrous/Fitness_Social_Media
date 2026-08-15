class PasswordResetCredentials {
  const PasswordResetCredentials({
    required this.token,
    required this.newPassword,
  });

  final String token;
  final String newPassword;
}
