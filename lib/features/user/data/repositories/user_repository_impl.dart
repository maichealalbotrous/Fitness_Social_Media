import 'package:fitness_social_app/features/user/data/datasources/user_remote_data_source.dart';
import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';
import 'package:fitness_social_app/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remoteDataSource);
  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getById(String id) async {
    return (await _remoteDataSource.getById(id)).toEntity();
  }

  @override
  Future<UserProfile> getByUsername(String username) async {
    return (await _remoteDataSource.getByUsername(username)).toEntity();
  }

  @override
  Future<UserProfile> updateProfile({String? bio, String? profilePictureUrl}) async {
    return (await _remoteDataSource.updateProfile(
      bio: bio,
      profilePictureUrl: profilePictureUrl,
    )).toEntity();
  }

  @override
  Future<String> uploadProfilePicture({required String fileName, required List<int> bytes}) {
    return _remoteDataSource.uploadProfilePicture(fileName: fileName, bytes: bytes);
  }
}
