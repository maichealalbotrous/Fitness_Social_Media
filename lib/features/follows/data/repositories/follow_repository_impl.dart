import 'package:fitness_social_app/features/follows/data/datasources/follow_remote_data_source.dart';
import 'package:fitness_social_app/features/follows/domain/entities/follow.dart';
import 'package:fitness_social_app/features/follows/domain/repositories/follow_repository.dart';

class FollowRepositoryImpl implements FollowRepository {
  const FollowRepositoryImpl(this._remoteDataSource);

  final FollowRemoteDataSource _remoteDataSource;

  @override
  Future<FollowStatus> toggleFollow(String targetUserId) {
    return _remoteDataSource.toggleFollow(targetUserId);
  }

  @override
  Future<List<FollowUser>> getFollowers() {
    return _remoteDataSource.getFollowers();
  }

  @override
  Future<List<FollowUser>> getFollowing() {
    return _remoteDataSource.getFollowing();
  }
}
