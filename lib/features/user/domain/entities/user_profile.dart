class UserProfile {
  const UserProfile({
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
}
