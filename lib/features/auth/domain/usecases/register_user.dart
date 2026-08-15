import 'package:fitness_social_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<String> call(RegisterCredentials credentials) {
    return _repository.register(credentials);
  }
}
