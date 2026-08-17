import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fitness_social_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_social_app/features/auth/domain/usecases/account_recovery_usecases.dart';
import 'package:fitness_social_app/features/auth/domain/usecases/login_user.dart';
import 'package:fitness_social_app/features/auth/domain/usecases/register_user.dart';
import 'package:fitness_social_app/features/auth/domain/usecases/session_usecases.dart';
import 'package:fitness_social_app/features/auth/presentation/controllers/account_recovery_controller.dart';
import 'package:fitness_social_app/features/auth/presentation/controllers/auth_controller.dart';

class AuthDependencies {
  const AuthDependencies._();

  static AuthRepositoryImpl createRepository() {
    return AuthRepositoryImpl(
      remoteDataSource: ApiAuthRemoteDataSource(ApiClient()),
      sessionStorage: SecureSessionStorage(),
    );
  }

  static AuthController createController() {
    final repository = createRepository();
    return AuthController(
      loginUser: LoginUser(repository),
      registerUser: RegisterUser(repository),
    );
  }

  static AccountRecoveryController createRecoveryController() {
    final repository = createRepository();
    return AccountRecoveryController(
      requestPasswordReset: RequestPasswordReset(repository),
      resetPassword: ResetPassword(repository),
      verifyEmail: VerifyEmail(repository),
    );
  }

  static HasActiveSession createHasActiveSession() {
    return HasActiveSession(createRepository());
  }

  static LogoutUser createLogoutUser() {
    return LogoutUser(createRepository());
  }
}
