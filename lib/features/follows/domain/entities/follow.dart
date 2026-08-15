class FollowStatus {
  const FollowStatus({required this.isFollowing, required this.message});

  final bool isFollowing;
  final String message;
}

class FollowUser {
  const FollowUser({required this.userId, this.username});

  final String userId;
  final String? username;
}
