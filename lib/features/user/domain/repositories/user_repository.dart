import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile> getById(String id);
  Future<UserProfile> getByUsername(String username);

  Future<UserProfile> updateProfile({
    String? bio,
    String? profilePictureUrl,
  });

  Future<String> uploadProfilePicture({
    required String fileName,
    required List<int> bytes,
  });
}
