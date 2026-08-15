class LoginCredentials {
  const LoginCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class RegisterCredentials {
  const RegisterCredentials({
    required this.username,
    required this.email,
    required this.password,
  });

  final String username;
  final String email;
  final String password;
}
