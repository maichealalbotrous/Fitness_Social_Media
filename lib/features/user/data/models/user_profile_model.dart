import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.profilePictureUrl,
  });

  final String id;
  final String username;
  final String email;
  final String? bio;
  final String? profilePictureUrl;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: _string(json, 'id'),
      username: _string(json, 'username'),
      email: _string(json, 'email'),
      bio: _nullableString(json, 'bio'),
      profilePictureUrl: _nullableString(json, 'profilePictureUrl'),
    );
  }

  UserProfile toEntity() => UserProfile(
        id: id,
        username: username,
        email: email,
        bio: bio,
        profilePictureUrl: profilePictureUrl,
      );
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[_pascal(key)];
  return value is String ? value : '';
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[_pascal(key)];
  return value is String && value.isNotEmpty ? value : null;
}

String _pascal(String value) => value[0].toUpperCase() + value.substring(1);
