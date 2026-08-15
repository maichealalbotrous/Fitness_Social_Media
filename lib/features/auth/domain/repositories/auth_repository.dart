import 'package:fitness_social_app/features/auth/domain/entities/auth_credentials.dart';

abstract interface class AuthRepository {
  Future<void> login(LoginCredentials credentials);

  Future<String> register(RegisterCredentials credentials);

  Future<bool> hasActiveSession();

  Future<void> logout();
}
