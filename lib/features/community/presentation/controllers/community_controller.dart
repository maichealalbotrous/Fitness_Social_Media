import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/domain/usecases/community_usecases.dart';

class CommunityController extends ChangeNotifier {
  CommunityController({
    required CreateCommunity createCommunity,
    required GetCommunity getCommunity,
    required JoinCommunity joinCommunity,
    required LeaveCommunity leaveCommunity,
    required HandleCommunityRequest handleRequest,
  })  : _createCommunity = createCommunity,
        _getCommunity = getCommunity,
        _joinCommunity = joinCommunity,
        _leaveCommunity = leaveCommunity,
        _handleRequest = handleRequest;

  final CreateCommunity _createCommunity;
  final GetCommunity _getCommunity;
  final JoinCommunity _joinCommunity;
  final LeaveCommunity _leaveCommunity;
  final HandleCommunityRequest _handleRequest;

  Community? _community;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Community? get community => _community;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> load(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) return;
    _beginLoading();
    try {
      _community = await _getCommunity(trimmedId);
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'تعذر تحميل المجتمع.';
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

  Future<void> join() => _runAction(
        action: () async {
          final community = _community;
          if (community == null) return null;
          return _joinCommunity(community.id);
        },
      );

  Future<void> leave() => _runAction(
        action: () async {
          final community = _community;
          if (community == null) return null;
          return _leaveCommunity(community.id);
        },
      );

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

  void _finishLoading() {
    _isLoading = false;
    notifyListeners();
  }
}
