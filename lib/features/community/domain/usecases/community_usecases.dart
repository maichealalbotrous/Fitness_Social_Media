import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/domain/repositories/community_repository.dart';

class CreateCommunity {
  const CreateCommunity(this._repository);
  final CommunityRepository _repository;

  Future<Community> call({
    required String name,
    String? description,
    String? imageUrl,
    required bool isPrivate,
  }) {
    return _repository.create(
      name: name,
      description: description,
      imageUrl: imageUrl,
      isPrivate: isPrivate,
    );
  }
}

class GetCommunity {
  const GetCommunity(this._repository);
  final CommunityRepository _repository;
  Future<Community> call(String id) => _repository.getById(id);
}

class GetMyCommunities {
  const GetMyCommunities(this._repository);
  final CommunityRepository _repository;

  Future<List<Community>> call() => _repository.getMyCommunities();
}

class JoinCommunity {
  const JoinCommunity(this._repository);
  final CommunityRepository _repository;
  Future<String> call(String id) => _repository.join(id);
}

class LeaveCommunity {
  const LeaveCommunity(this._repository);
  final CommunityRepository _repository;
  Future<String> call(String id) => _repository.leave(id);
}

class HandleCommunityRequest {
  const HandleCommunityRequest(this._repository);
  final CommunityRepository _repository;

  Future<String> call({required String requestId, required bool accepted}) {
    return _repository.handleRequest(
      requestId: requestId,
      accepted: accepted,
    );
  }
}

class GetCommunityMembers {
  const GetCommunityMembers(this._repository);
  final CommunityRepository _repository;

  Future<List<CommunityMember>> call(String communityId) {
    return _repository.getMembers(communityId);
  }
}

class MakeCommunityAdmin {
  const MakeCommunityAdmin(this._repository);
  final CommunityRepository _repository;

  Future<String> call({required String communityId, required String userId}) {
    return _repository.makeAdmin(communityId: communityId, userId: userId);
  }
}

class RemoveCommunityAdmin {
  const RemoveCommunityAdmin(this._repository);
  final CommunityRepository _repository;

  Future<String> call({required String communityId, required String userId}) {
    return _repository.removeAdmin(communityId: communityId, userId: userId);
  }
}

class RemoveCommunityMember {
  const RemoveCommunityMember(this._repository);
  final CommunityRepository _repository;

  Future<String> call({required String communityId, required String userId}) {
    return _repository.removeMember(communityId: communityId, userId: userId);
  }
}
