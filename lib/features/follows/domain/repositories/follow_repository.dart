import 'package:fitness_social_app/features/follows/domain/entities/follow.dart';

abstract interface class FollowRepository {
  Future<FollowStatus> toggleFollow(String targetUserId);

  Future<List<FollowUser>> getFollowers();

  Future<List<FollowUser>> getFollowing();
}
