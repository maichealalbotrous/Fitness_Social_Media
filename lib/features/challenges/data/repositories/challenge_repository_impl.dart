import '../../domain/entities/challenge.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/challenge_remote_data_source.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  const ChallengeRepositoryImpl(this._remote);
  final ChallengeRemoteDataSource _remote;

  @override
  Future<List<Challenge>> getJoinable() => _remote.getJoinable();

  @override
  Future<List<Challenge>> getUserChallenges() => _remote.getUserChallenges();

  @override
  Future<List<Challenge>> getByCommunity(String communityId) => _remote.getByCommunity(communityId);

  @override
  Future<List<Challenge>> getActiveByCommunity(String communityId) => _remote.getActiveByCommunity(communityId);

  @override
  Future<Challenge> getById(String challengeId) => _remote.getById(challengeId);

  @override
  Future<Challenge> create(String communityId, Map<String, dynamic> body) => _remote.create(communityId, body);

  @override
  Future<ChallengeActionResult> join(String challengeId) async =>
      ChallengeActionResult(message: await _remote.join(challengeId));

  @override
  Future<ChallengeActionResult> updateParticipant(String challengeId, double progress) async =>
      ChallengeActionResult(message: await _remote.updateParticipant(challengeId, progress));
}
