import 'package:fitness_social_app/features/auth/domain/entities/password_reset_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordReset {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<String> call(String email) {
    return _repository.requestPasswordReset(email);
  }
}

class ResetPassword {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  Future<String> call(PasswordResetCredentials credentials) {
    return _repository.resetPassword(credentials);
  }
}

class VerifyEmail {
  const VerifyEmail(this._repository);

  final AuthRepository _repository;

  Future<String> call(String token) {
    return _repository.verifyEmail(token);
  }
}
