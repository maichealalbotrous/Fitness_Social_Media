import 'package:fitness_social_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/entities/password_reset_credentials.dart';

abstract interface class AuthRepository {
  Future<void> login(LoginCredentials credentials);

  Future<String> register(RegisterCredentials credentials);

  Future<String> requestPasswordReset(String email);

  Future<String> resetPassword(PasswordResetCredentials credentials);

  Future<String> verifyEmail(String token);

  Future<bool> hasActiveSession();

  Future<void> logout();
}
