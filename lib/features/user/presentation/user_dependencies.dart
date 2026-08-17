import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/user/data/datasources/user_remote_data_source.dart';
import 'package:fitness_social_app/features/user/data/repositories/user_repository_impl.dart';
import 'package:fitness_social_app/features/user/domain/usecases/user_usecases.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/user_controller.dart';

class UserDependencies {
  const UserDependencies._();

  static UserController createController() {
    final repository = UserRepositoryImpl(
      ApiUserRemoteDataSource(
        ApiClient(sessionStorage: SecureSessionStorage()),
      ),
    );
    return UserController(
      getById: GetUserById(repository),
      getByUsername: GetUserByUsername(repository),
      updateProfile: UpdateUserProfile(repository),
      uploadProfilePicture: UploadUserProfilePicture(repository),
    );
  }
}
