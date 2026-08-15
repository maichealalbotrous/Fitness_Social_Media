import 'package:fitness_social_app/features/follows/domain/entities/follow.dart';
import 'package:fitness_social_app/features/follows/domain/repositories/follow_repository.dart';

class ToggleFollow {
  const ToggleFollow(this._repository);

  final FollowRepository _repository;

  Future<FollowStatus> call(String targetUserId) {
    return _repository.toggleFollow(targetUserId);
  }
}

class GetFollowers {
  const GetFollowers(this._repository);

  final FollowRepository _repository;

  Future<List<FollowUser>> call() => _repository.getFollowers();
}

class GetFollowing {
  const GetFollowing(this._repository);

  final FollowRepository _repository;

  Future<List<FollowUser>> call() => _repository.getFollowing();
}
