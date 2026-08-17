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
    required GetMyCommunities getMyCommunities,
    required JoinCommunity joinCommunity,
    required LeaveCommunity leaveCommunity,
    required HandleCommunityRequest handleRequest,
    required SessionStorage sessionStorage,
  })  : _createCommunity = createCommunity,
        _getCommunity = getCommunity,
        _getMyCommunities = getMyCommunities,
        _joinCommunity = joinCommunity,
        _leaveCommunity = leaveCommunity,
        _handleRequest = handleRequest,
        _sessionStorage = sessionStorage;

  final CreateCommunity _createCommunity;
  final GetCommunity _getCommunity;
  final GetMyCommunities _getMyCommunities;
  final JoinCommunity _joinCommunity;
  final LeaveCommunity _leaveCommunity;
  final HandleCommunityRequest _handleRequest;
  final SessionStorage _sessionStorage;

  Community? _community;
  bool _isRequestPending = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<Community> _myCommunities = const <Community>[];

  Community? get community => _community;
  List<Community> get myCommunities => _myCommunities;
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
      _community = loaded.copyWith(
        isOwner: loaded.isOwner || (userId != null && loaded.ownerId == userId),
        isAdmin: loaded.isAdmin || (userId != null && loaded.adminIds.contains(userId)),
      );
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'تعذر تحميل المجتمع.';
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
      _errorMessage = 'تعذر تحميل مجتمعاتك.';
    } finally {
      _finishLoading();
    }
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
      _successMessage = 'تم إنشاء المجتمع بنجاح.';
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'تعذر إنشاء المجتمع.';
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
      final normalized = message.toLowerCase();
      final joined = normalized.contains('successfully joined') ||
          normalized == 'joined' ||
          normalized.contains('joined the community');
      _isRequestPending = !joined && normalized.contains('request');
      _community = community.copyWith(
        isMember: joined,
        memberCount: joined ? community.memberCount + 1 : community.memberCount,
      );
      _successMessage = message;
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'تعذر تنفيذ طلب الانضمام.';
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
      _errorMessage = 'تعذر مغادرة المجتمع.';
    } finally {
      _finishLoading();
    }
  }

  Future<void> handleRequest({required String requestId, required bool accepted}) =>
      _runAction(
        action: () => _handleRequest(
          requestId: requestId,
          accepted: accepted,
        ),
      );

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
      _errorMessage = 'تعذر تنفيذ العملية.';
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
