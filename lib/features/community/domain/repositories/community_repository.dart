import 'package:fitness_social_app/features/community/domain/entities/community.dart';

abstract interface class CommunityRepository {
  Future<Community> create({
    required String name,
    String? description,
    String? imageUrl,
    required bool isPrivate,
  });

  Future<Community> getById(String id);
  Future<Community> getByName(String name);
  Future<List<CommunityJoinRequest>> getRequests(String communityId);
  Future<List<Community>> getMyCommunities();
  Future<List<CommunityMember>> getMembers(String communityId);

  Future<String> join(String id);

  Future<String> leave(String id);

  Future<String> handleRequest({
    required String requestId,
    required bool accepted,
  });

  Future<String> makeAdmin({required String communityId, required String userId});
  Future<String> removeAdmin({required String communityId, required String userId});
  Future<String> removeMember({required String communityId, required String userId});
}
