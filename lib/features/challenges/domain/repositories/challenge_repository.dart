import '../entities/challenge.dart';

abstract interface class ChallengeRepository {
  Future<List<Challenge>> getJoinable();
  Future<List<Challenge>> getUserChallenges();
  Future<List<Challenge>> getByCommunity(String communityId);
  Future<List<Challenge>> getActiveByCommunity(String communityId);
  Future<Challenge> getById(String challengeId);
  Future<Challenge> create(String communityId, Map<String, dynamic> body);
  Future<ChallengeActionResult> join(String challengeId);
  Future<ChallengeActionResult> updateParticipant(String challengeId, double progress);
}
