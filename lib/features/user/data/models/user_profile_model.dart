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
      id: _firstString(json, const ['id', 'userId', 'Id', 'UserId']),
      username: _firstString(json, const ['username', 'userName', 'Username', 'UserName']),
      email: _firstString(json, const ['email', 'Email']),
      bio: _firstNullableString(json, const ['bio', 'Bio']),
      profilePictureUrl: _firstNullableString(
        json,
        const ['profilePictureUrl', 'ProfilePictureUrl', 'profilePicture', 'ProfilePicture'],
      ),
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

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return '';
}

String? _firstNullableString(Map<String, dynamic> json, List<String> keys) {
  final value = _firstString(json, keys);
  return value.isEmpty ? null : value;
}
