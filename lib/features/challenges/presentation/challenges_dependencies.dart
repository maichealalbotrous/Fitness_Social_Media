import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';

import '../data/datasources/challenge_remote_data_source.dart';
import '../data/repositories/challenge_repository_impl.dart';
import '../domain/usecases/challenge_usecases.dart';
import 'controllers/challenges_controller.dart';

class ChallengesDependencies {
  const ChallengesDependencies._();

  static ChallengesController createController() {
    final apiClient = ApiClient(sessionStorage: SecureSessionStorage());
    final remote = ApiChallengeRemoteDataSource(apiClient);
    final repository = ChallengeRepositoryImpl(remote);
    return ChallengesController(
      getJoinable: GetJoinableChallenges(repository),
      getUserChallenges: GetUserChallenges(repository),
      getCommunityChallenges: GetCommunityChallenges(repository),
      getActiveCommunityChallenges: GetActiveCommunityChallenges(repository),
      getById: GetChallengeById(repository),
      create: CreateChallenge(repository),
      join: JoinChallenge(repository),
      updateParticipant: UpdateChallengeParticipant(repository),
    );
  }
}
