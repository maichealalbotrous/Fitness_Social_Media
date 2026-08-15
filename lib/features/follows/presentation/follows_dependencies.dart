import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/follows/data/datasources/follow_remote_data_source.dart';
import 'package:fitness_social_app/features/follows/data/repositories/follow_repository_impl.dart';
import 'package:fitness_social_app/features/follows/domain/usecases/follow_usecases.dart';
import 'package:fitness_social_app/features/follows/presentation/controllers/follow_controller.dart';

class FollowsDependencies {
  const FollowsDependencies._();

  static FollowController createController() {
    final repository = FollowRepositoryImpl(
      ApiFollowRemoteDataSource(
        ApiClient(sessionStorage: SecureSessionStorage()),
      ),
    );

    return FollowController(
      toggleFollow: ToggleFollow(repository),
      getFollowers: GetFollowers(repository),
      getFollowing: GetFollowing(repository),
    );
  }
}
