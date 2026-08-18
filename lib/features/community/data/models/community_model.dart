import 'package:fitness_social_app/features/community/domain/entities/community.dart';

class CommunityModel {
  const CommunityModel({
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

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      description: _nullableString(json, 'description'),
      imageUrl: _nullableString(json, 'imageUrl'),
      isPrivate: _bool(json, 'isPrivate'),
      ownerId: _string(json, 'ownerId'),
      isOwner: _bool(json, 'isOwner'),
      isAdmin: _bool(json, 'isAdmin'),
      isMember: _bool(json, 'isMember'),
      adminIds: _strings(json['adminIds'] ?? json['AdminIds']),
      memberCount: _integer(json, 'memberCount'),
    );
  }

  Community toEntity() => Community(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        isPrivate: isPrivate,
        ownerId: ownerId,
        isOwner: isOwner,
        isAdmin: isAdmin,
        isMember: isMember,
        adminIds: adminIds,
        memberCount: memberCount,
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

bool _bool(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[_pascal(key)];
  if (value is bool) return value;
  return value is String && value.toLowerCase() == 'true';
}

int _integer(Map<String, dynamic> json, String key) {
  final value = json[key] ?? json[_pascal(key)];
  return value is num ? value.toInt() : 0;
}

List<String> _strings(dynamic value) {
  if (value is! List) return const <String>[];
  return value.whereType<String>().toList(growable: false);
}

String _pascal(String value) => value[0].toUpperCase() + value.substring(1);

class CommunityMemberModel {
  const CommunityMemberModel({
    required this.userId,
    required this.userName,
    required this.isAdmin,
  });

  final String userId;
  final String userName;
  final bool isAdmin;

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      userId: _string(json, 'userId'),
      userName: _string(json, 'userName'),
      isAdmin: _bool(json, 'isAdmin'),
    );
  }
}
