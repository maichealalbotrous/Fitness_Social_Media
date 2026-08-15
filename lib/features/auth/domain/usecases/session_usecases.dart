import 'package:fitness_social_app/features/auth/domain/repositories/auth_repository.dart';

class HasActiveSession {
  const HasActiveSession(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.hasActiveSession();
}

class LogoutUser {
  const LogoutUser(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
