import 'package:fitness_social_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<void> call(LoginCredentials credentials) {
    return _repository.login(credentials);
  }
}
