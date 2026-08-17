class Community {
  const Community({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isPrivate,
    required this.ownerId,
    required this.isOwner,
    required this.isAdmin,
    required this.isMember,
    required this.adminIds,
    required this.memberCount,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isPrivate;
  final String ownerId;
  final bool isOwner;
  final bool isAdmin;
  final bool isMember;
  final List<String> adminIds;
  final int memberCount;
}

class CommunityActionResult {
  const CommunityActionResult({required this.message, this.community});

  final String message;
  final Community? community;
}
