import 'package:fitness_social_app/features/community/data/datasources/community_remote_data_source.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/domain/repositories/community_repository.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  const CommunityRepositoryImpl(this._remoteDataSource);
  final CommunityRemoteDataSource _remoteDataSource;

  @override
  Future<Community> create({
    required String name,
    String? description,
    String? imageUrl,
    required bool isPrivate,
  }) async {
    final model = await _remoteDataSource.create(
      name: name,
      description: description,
      imageUrl: imageUrl,
      isPrivate: isPrivate,
    );
    return model.toEntity();
  }

  @override
  Future<Community> getById(String id) async {
    return (await _remoteDataSource.getById(id)).toEntity();
  }

  @override
  Future<String> join(String id) => _remoteDataSource.join(id);

  @override
  Future<String> leave(String id) => _remoteDataSource.leave(id);

  @override
  Future<String> handleRequest({required String requestId, required bool accepted}) {
    return _remoteDataSource.handleRequest(
      requestId: requestId,
      accepted: accepted,
    );
  }
}
