import 'package:fitness_social_app/features/community/domain/entities/community.dart';

abstract interface class CommunityRepository {
  Future<Community> create({
    required String name,
    String? description,
    String? imageUrl,
    required bool isPrivate,
  });

  Future<Community> getById(String id);
  Future<List<Community>> getMyCommunities();

  Future<String> join(String id);

  Future<String> leave(String id);

  Future<String> handleRequest({
    required String requestId,
    required bool accepted,
  });
}
