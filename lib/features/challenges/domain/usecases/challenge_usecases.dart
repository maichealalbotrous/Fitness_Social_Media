import '../entities/challenge.dart';
import '../repositories/challenge_repository.dart';

class GetJoinableChallenges {
  const GetJoinableChallenges(this._repository);
  final ChallengeRepository _repository;
  Future<List<Challenge>> call() => _repository.getJoinable();
}

class GetUserChallenges {
  const GetUserChallenges(this._repository);
  final ChallengeRepository _repository;
  Future<List<Challenge>> call() => _repository.getUserChallenges();
}

class GetCommunityChallenges {
  const GetCommunityChallenges(this._repository);
  final ChallengeRepository _repository;
  Future<List<Challenge>> call(String communityId) => _repository.getByCommunity(communityId);
}

class GetActiveCommunityChallenges {
  const GetActiveCommunityChallenges(this._repository);
  final ChallengeRepository _repository;
  Future<List<Challenge>> call(String communityId) => _repository.getActiveByCommunity(communityId);
}

class GetChallengeById {
  const GetChallengeById(this._repository);
  final ChallengeRepository _repository;
  Future<Challenge> call(String challengeId) => _repository.getById(challengeId);
}

class CreateChallenge {
  const CreateChallenge(this._repository);
  final ChallengeRepository _repository;
  Future<Challenge> call(String communityId, Map<String, dynamic> body) => _repository.create(communityId, body);
}

class JoinChallenge {
  const JoinChallenge(this._repository);
  final ChallengeRepository _repository;
  Future<ChallengeActionResult> call(String challengeId) => _repository.join(challengeId);
}

class UpdateChallengeParticipant {
  const UpdateChallengeParticipant(this._repository);
  final ChallengeRepository _repository;
  Future<ChallengeActionResult> call(String challengeId, double progress) => _repository.updateParticipant(challengeId, progress);
}
