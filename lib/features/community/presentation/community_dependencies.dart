import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/community/data/datasources/community_remote_data_source.dart';
import 'package:fitness_social_app/features/community/data/repositories/community_repository_impl.dart';
import 'package:fitness_social_app/features/community/domain/usecases/community_usecases.dart';
import 'package:fitness_social_app/features/community/presentation/controllers/community_controller.dart';

class CommunityDependencies {
  const CommunityDependencies._();

  static CommunityController createController() {
    final repository = CommunityRepositoryImpl(
      ApiCommunityRemoteDataSource(
        ApiClient(sessionStorage: SecureSessionStorage()),
      ),
    );
    return CommunityController(
      createCommunity: CreateCommunity(repository),
      getCommunity: GetCommunity(repository),
      joinCommunity: JoinCommunity(repository),
      leaveCommunity: LeaveCommunity(repository),
      handleRequest: HandleCommunityRequest(repository),
      sessionStorage: SecureSessionStorage(),
    );
  }
}
