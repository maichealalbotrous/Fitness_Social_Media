import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fitness_social_app/features/auth/domain/entities/auth_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/entities/password_reset_credentials.dart';
import 'package:fitness_social_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionStorage sessionStorage,
  })  : _remoteDataSource = remoteDataSource,
        _sessionStorage = sessionStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final SessionStorage _sessionStorage;

  @override
  Future<bool> hasActiveSession() async {
    final token = await _sessionStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> login(LoginCredentials credentials) async {
    final token = await _remoteDataSource.login(credentials);
    await _sessionStorage.saveAccessToken(token);
  }

  @override
  Future<void> logout() {
    return _sessionStorage.clear();
  }

  @override
  Future<String> register(RegisterCredentials credentials) {
    return _remoteDataSource.register(credentials);
  }

  @override
  Future<String> requestPasswordReset(String email) {
    return _remoteDataSource.requestPasswordReset(email);
  }

  @override
  Future<String> resetPassword(PasswordResetCredentials credentials) {
    return _remoteDataSource.resetPassword(credentials);
  }

  @override
  Future<String> verifyEmail(String token) {
    return _remoteDataSource.verifyEmail(token);
  }
}
