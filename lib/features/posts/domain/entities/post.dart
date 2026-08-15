class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.content,
    required this.mediaUrls,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByCurrentUser,
    required this.createdAt,
    this.communityId,
  });

  final String id;
  final String authorId;
  final String content;
  final List<String> mediaUrls;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;
  final String? communityId;

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
  }) {
    return Post(
      id: id,
      authorId: authorId,
      content: content,
      mediaUrls: mediaUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByCurrentUser:
          isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt,
      communityId: communityId,
    );
  }
}

class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.parentCommentId,
  });

  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final String? parentCommentId;
}
