import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitness_social_app/features/community/data/models/community_model.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';

class CommunityLocalStorage {
  static const _key = 'my_communities';

  Future<List<Community>> read() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_key) ?? const <String>[];
    return values
        .map((value) {
          try {
            return CommunityModel.fromJson(
              jsonDecode(value) as Map<String, dynamic>,
            ).toEntity();
          } catch (_) {
            return null;
          }
        })
        .whereType<Community>()
        .toList(growable: false);
  }

  Future<void> save(Community community) async {
    final communities = await read();
    final updated = <Community>[
      ...communities.where((item) => item.id != community.id),
      community,
    ];
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      updated.map(_encode).toList(growable: false),
    );
  }

  Future<void> remove(String id) async {
    final communities = await read();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      communities.where((item) => item.id != id).map(_encode).toList(growable: false),
    );
  }

  String _encode(Community community) => jsonEncode({
        'id': community.id,
        'name': community.name,
        'description': community.description,
        'imageUrl': community.imageUrl,
        'isPrivate': community.isPrivate,
        'ownerId': community.ownerId,
        'isOwner': community.isOwner,
        'isAdmin': community.isAdmin,
        'isMember': community.isMember,
        'adminIds': community.adminIds,
        'memberCount': community.memberCount,
      });
}
