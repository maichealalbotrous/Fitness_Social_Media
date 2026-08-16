import 'package:fitness_social_app/features/posts/domain/entities/post.dart';

class PostModel {
  const PostModel({
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: _string(json, 'id'),
      authorId: _string(json, 'authorId'),
      content: _string(json, 'content'),
      mediaUrls: _strings(json['mediaUrls'] ?? json['MediaUrls']),
      likesCount: _integer(json, 'likesCount'),
      commentsCount: _integer(json, 'commentsCount'),
      isLikedByCurrentUser:
          _boolean(json, 'isLikedByCurrentUser') ||
          _boolean(json, 'IsLikedByCurrentUser'),
      createdAt: DateTime.tryParse(
            _string(json, 'createdAt', fallbackKey: 'CreatedAt'),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      communityId: _nullableString(json, 'communityId'),
    );
  }

  Post toEntity() {
    return Post(
      id: id,
      authorId: authorId,
      content: content,
      mediaUrls: mediaUrls,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isLikedByCurrentUser: isLikedByCurrentUser,
      createdAt: createdAt,
      communityId: communityId,
    );
  }
}

class CommentModel {
  const CommentModel({
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

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: _string(json, 'id'),
      postId: _string(json, 'postId'),
      authorId: _string(json, 'authorId'),
      content: _string(json, 'content'),
      parentCommentId: _nullableString(json, 'parentCommentId'),
      createdAt: DateTime.tryParse(
            _string(json, 'createdAt', fallbackKey: 'CreatedAt'),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      postId: postId,
      authorId: authorId,
      content: content,
      parentCommentId: parentCommentId,
      createdAt: createdAt,
    );
  }
}

String _string(
  Map<String, dynamic> json,
  String key, {
  String? fallbackKey,
}) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  final value =
      json[key] ?? json[pascalKey] ?? (fallbackKey == null ? null : json[fallbackKey]);
  return value is String ? value : '';
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[key[0].toUpperCase() + key.substring(1)];
  return value is String && value.isNotEmpty ? value : null;
}

int _integer(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[key[0].toUpperCase() + key.substring(1)];
  return value is num ? value.toInt() : 0;
}

bool _boolean(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[key[0].toUpperCase() + key.substring(1)];
  return value == true;
}

List<String> _strings(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }
  return value.whereType<String>().toList(growable: false);
}
