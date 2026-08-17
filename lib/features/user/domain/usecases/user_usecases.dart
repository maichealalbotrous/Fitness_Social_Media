import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';
import 'package:fitness_social_app/features/user/domain/repositories/user_repository.dart';

class GetUserById {
  const GetUserById(this._repository);
  final UserRepository _repository;
  Future<UserProfile> call(String id) => _repository.getById(id);
}

class GetUserByUsername {
  const GetUserByUsername(this._repository);
  final UserRepository _repository;
  Future<UserProfile> call(String username) => _repository.getByUsername(username);
}

class UpdateUserProfile {
  const UpdateUserProfile(this._repository);
  final UserRepository _repository;

  Future<UserProfile> call({required String bio, String? profilePictureUrl}) {
    return _repository.updateProfile(
      bio: bio,
      profilePictureUrl: profilePictureUrl,
    );
  }
}

class UploadUserProfilePicture {
  const UploadUserProfilePicture(this._repository);
  final UserRepository _repository;

  Future<String> call({required String fileName, required List<int> bytes}) {
    return _repository.uploadProfilePicture(fileName: fileName, bytes: bytes);
  }
}
