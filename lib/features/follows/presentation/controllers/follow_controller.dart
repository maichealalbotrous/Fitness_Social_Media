import 'package:flutter/foundation.dart';

import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/follows/domain/entities/follow.dart';
import 'package:fitness_social_app/features/follows/domain/usecases/follow_usecases.dart';

class FollowController extends ChangeNotifier {
  FollowController({
    required ToggleFollow toggleFollow,
    required GetFollowers getFollowers,
    required GetFollowing getFollowing,
  })  : _toggleFollow = toggleFollow,
        _getFollowers = getFollowers,
        _getFollowing = getFollowing;

  final ToggleFollow _toggleFollow;
  final GetFollowers _getFollowers;
  final GetFollowing _getFollowing;

  List<FollowUser> _followers = const <FollowUser>[];
  List<FollowUser> _following = const <FollowUser>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<FollowUser> get followers => _followers;
  List<FollowUser> get following => _following;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<FollowStatus?> toggle(String targetUserId) async {
    try {
      _errorMessage = null;
      final status = await _toggleFollow(targetUserId);
      notifyListeners();
      return status;
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
    } catch (_) {
      _errorMessage = 'Unable to update follow status. Please try again.';
    }
    notifyListeners();
    return null;
  }

  Future<void> loadFollowers() async {
    await _load(() async => _followers = await _getFollowers());
  }

  Future<void> loadFollowing() async {
    await _load(() async => _following = await _getFollowing());
  }

  Future<void> _load(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on ApiException catch (exception) {
      _errorMessage = exception.message;
    } catch (_) {
      _errorMessage = 'Unable to load follow data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
