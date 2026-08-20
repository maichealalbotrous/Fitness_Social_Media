import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/user_sessions/data/user_session_remote_data_source.dart';
import 'package:fitness_social_app/features/user_sessions/data/user_session_repository_impl.dart';
import 'package:fitness_social_app/features/user_sessions/presentation/user_session_controller.dart';

class UserSessionDependencies {
  const UserSessionDependencies._();
  static UserSessionController createController() => UserSessionController(UserSessionRepositoryImpl(ApiUserSessionRemoteDataSource(ApiClient(sessionStorage: SecureSessionStorage()))));
}
