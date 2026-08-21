import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/domain/usecases/community_usecases.dart';

class CommunityController extends ChangeNotifier {
  CommunityController({
    required CreateCommunity createCommunity,
    required GetCommunity getCommunity,
    required SearchCommunityByName searchCommunityByName,
    required GetCommunityRequests getCommunityRequests,
    required GetMyCommunities getMyCommunities,
    required JoinCommunity joinCommunity,
    required LeaveCommunity leaveCommunity,
    required HandleCommunityRequest handleRequest,
    required GetCommunityMembers getCommunityMembers,
    required MakeCommunityAdmin makeCommunityAdmin,
    required RemoveCommunityAdmin removeCommunityAdmin,
    required RemoveCommunityMember removeCommunityMember,
    required SessionStorage sessionStorage,
  })  : _createCommunity = createCommunity,
        _getCommunity = getCommunity,
        _searchCommunityByName = searchCommunityByName,
        _getCommunityRequests = getCommunityRequests,
        _getMyCommunities = getMyCommunities,
        _joinCommunity = joinCommunity,
        _leaveCommunity = leaveCommunity,
        _handleRequest = handleRequest,
        _getCommunityMembers = getCommunityMembers,
        _makeCommunityAdmin = makeCommunityAdmin,
        _removeCommunityAdmin = removeCommunityAdmin,
        _removeCommunityMember = removeCommunityMember,
        _sessionStorage = sessionStorage;

  final CreateCommunity _createCommunity;
  final GetCommunity _getCommunity;
  final SearchCommunityByName _searchCommunityByName;
  final GetCommunityRequests _getCommunityRequests;
  final GetMyCommunities _getMyCommunities;
  final JoinCommunity _joinCommunity;
  final LeaveCommunity _leaveCommunity;
  final HandleCommunityRequest _handleRequest;
  final GetCommunityMembers _getCommunityMembers;
  final MakeCommunityAdmin _makeCommunityAdmin;
  final RemoveCommunityAdmin _removeCommunityAdmin;
  final RemoveCommunityMember _removeCommunityMember;
  final SessionStorage _sessionStorage;

  Community? _community;
  bool _isRequestPending = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<Community> _myCommunities = const <Community>[];
  List<CommunityMember> _members = const <CommunityMember>[];
  List<CommunityJoinRequest> _requests = const <CommunityJoinRequest>[];

  Community? get community => _community;
  List<Community> get myCommunities => _myCommunities;
  List<CommunityMember> get members => _members;
  List<CommunityJoinRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  bool get isRequestPending => _isRequestPending;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> load(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return;
    _beginLoading();
    try {
      final loaded = await _getCommunity(trimmedId);
      final userId = await _currentUserId();
      final isOwner = loaded.isOwner || (userId != null && loaded.ownerId == userId);
      _community = loaded.copyWith(
        isOwner: isOwner,
        // GET /api/Community/{id} in the current backend uses a default
        // IsMember value. Membership must be confirmed by /members.
        isAdmin: isOwner,
        isMember: isOwner,
      );
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load the community.';
    } finally {
      _finishLoading();
    }
  }

  Future<void> searchByName(String name) async {
    final value = name.trim();
    if (value.isEmpty) return;
    _beginLoading();
    try { _community = await _searchCommunityByName(value); _errorMessage = null; }
    on ApiException catch (error) { _errorMessage = error.message; }
    catch (_) { _errorMessage = 'Unable to search for the community.'; }
    finally { _finishLoading(); }
  }

  Future<void> loadRequests(String communityId) async {
    _beginLoading();
    try { _requests = await _getCommunityRequests(communityId); _errorMessage = null; }
    on ApiException catch (error) { _errorMessage = error.message; }
    catch (_) { _errorMessage = 'Unable to load join requests.'; }
    finally { _finishLoading(); }
  }

  Future<void> loadMembers(String communityId) async {
    _beginLoading();
    try {
      _members = await _getCommunityMembers(communityId);
      final current = _community;
      final userId = await _currentUserId();
      if (current != null && current.id == communityId && userId != null) {
        CommunityMember? member;
        for (final item in _members) {
          if (item.userId == userId) {
            member = item;
            break;
          }
        }
        _community = current.copyWith(
          isMember: member != null || current.isOwner,
          isAdmin: member?.isAdmin == true || current.isOwner,
        );
      }
      _errorMessage = null;
    } on ApiException catch (error) {
      _members = const <CommunityMember>[];
      final current = _community;
      if (current != null && current.id == communityId) {
        _community = current.copyWith(
          isMember: current.isOwner,
          isAdmin: current.isOwner,
        );
      }
      // A non-member receives 403 from the members endpoint; that is a
      // normal state for the lookup page, not a visible loading error.
      _errorMessage = error.statusCode == 403 ? null : error.message;
    } catch (_) {
      _members = const <CommunityMember>[];
      final current = _community;
      if (current != null && current.id == communityId) {
        _community = current.copyWith(
          isMember: current.isOwner,
          isAdmin: current.isOwner,
        );
      }
      _errorMessage = 'Unable to load community members.';
    } finally {
      _finishLoading();
    }
  }

  Future<void> loadMyCommunities() async {
    _beginLoading();
    try {
      _myCommunities = await _getMyCommunities();
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load your communities.';
    } finally {
      _finishLoading();
    }
  }

  void restoreLocalMembership(Community cached) {
    final current = _community;
    if (current == null || current.id != cached.id || !cached.isMember) return;
    _community = current.copyWith(
      isMember: true,
      isAdmin: current.isAdmin || cached.isAdmin,
      isOwner: current.isOwner || cached.isOwner,
      memberCount: cached.memberCount > current.memberCount
          ? cached.memberCount
          : current.memberCount,
    );
    notifyListeners();
  }

  Future<void> create({
    required String name,
    String? description,
    String? imageUrl,
    required bool isPrivate,
  }) async {
    _beginLoading();
    try {
      _community = await _createCommunity(
        name: name.trim(),
        description: description?.trim().isEmpty == true ? null : description?.trim(),
        imageUrl: imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim(),
        isPrivate: isPrivate,
      );
      _isRequestPending = false;
      _successMessage = 'Community created successfully.';
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to create the community.';
    } finally {
      _finishLoading();
    }
  }

  Future<void> join() async {
    final community = _community;
    if (community == null) return;
    _beginLoading();
    try {
      final message = await _joinCommunity(community.id);
      // A successful join call adds the user immediately for a public
      // community and creates a pending request for a private community.
      // The API message can vary by backend version, so use the community
      // privacy flag instead of parsing response text.
      final joined = !community.isPrivate;
      _isRequestPending = community.isPrivate;
      _community = community.copyWith(
        isMember: joined,
        memberCount: joined ? community.memberCount + 1 : community.memberCount,
      );
      _successMessage = message;
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to process the join request.';
    } finally {
      _finishLoading();
    }
  }

  Future<void> leave() async {
    final community = _community;
    if (community == null) return;
    _beginLoading();
    try {
      final message = await _leaveCommunity(community.id);
      _community = community.copyWith(
        isMember: false,
        memberCount: community.memberCount > 0 ? community.memberCount - 1 : 0,
      );
      _isRequestPending = false;
      _successMessage = message;
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to leave the community.';
    } finally {
      _finishLoading();
    }
  }

  Future<void> makeAdmin(String userId) => _runMemberAction(
        action: () => _makeCommunityAdmin(
          communityId: _community!.id,
          userId: userId,
        ),
      );

  Future<void> removeAdmin(String userId) => _runMemberAction(
        action: () => _removeCommunityAdmin(
          communityId: _community!.id,
          userId: userId,
        ),
      );

  Future<void> removeMember(String userId) => _runMemberAction(
        action: () => _removeCommunityMember(
          communityId: _community!.id,
          userId: userId,
        ),
      );

  Future<void> handleRequest({required String requestId, required bool accepted}) =>
      _runAction(
        action: () => _handleRequest(
          requestId: requestId,
          accepted: accepted,
        ),
      );

  Future<void> _runMemberAction({required Future<String> Function() action}) async {
    _beginLoading();
    try {
      _successMessage = await action();
      _errorMessage = null;
      if (_community != null) await loadMembers(_community!.id);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to process the member operation.';
    } finally {
      _finishLoading();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> _runAction({required Future<String?> Function() action}) async {
    _beginLoading();
    try {
      _successMessage = await action();
      _errorMessage = null;
      final id = _community?.id;
      if (id != null) await load(id);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to complete the operation.';
    } finally {
      _finishLoading();
    }
  }

  void _beginLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> _currentUserId() async {
    final token = await _sessionStorage.readAccessToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) return null;
      const keys = [
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
        'nameid',
        'sub',
      ];
      for (final key in keys) {
        final value = payload[key];
        if (value is String && value.isNotEmpty) return value;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _finishLoading() {
    _isLoading = false;
    notifyListeners();
  }
}
