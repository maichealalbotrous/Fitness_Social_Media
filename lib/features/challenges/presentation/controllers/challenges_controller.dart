import 'package:flutter/foundation.dart';

import '../../domain/entities/challenge.dart';
import '../../domain/usecases/challenge_usecases.dart';

class ChallengesController extends ChangeNotifier {
  ChallengesController({
    required GetJoinableChallenges getJoinable,
    required GetUserChallenges getUserChallenges,
    required GetCommunityChallenges getCommunityChallenges,
    required GetActiveCommunityChallenges getActiveCommunityChallenges,
    required GetChallengeById getById,
    required CreateChallenge create,
    required JoinChallenge join,
    required UpdateChallengeParticipant updateParticipant,
  })  : _getJoinable = getJoinable,
        _getUserChallenges = getUserChallenges,
        _getCommunityChallenges = getCommunityChallenges,
        _getActiveCommunityChallenges = getActiveCommunityChallenges,
        _getById = getById,
        _create = create,
        _join = join,
        _updateParticipant = updateParticipant;

  final GetJoinableChallenges _getJoinable;
  final GetUserChallenges _getUserChallenges;
  final GetCommunityChallenges _getCommunityChallenges;
  final GetActiveCommunityChallenges _getActiveCommunityChallenges;
  final GetChallengeById _getById;
  final CreateChallenge _create;
  final JoinChallenge _join;
  final UpdateChallengeParticipant _updateParticipant;

  List<Challenge> joinable = const [];
  List<Challenge> myChallenges = const [];
  List<Challenge> communityChallenges = const [];
  List<Challenge> activeChallenges = const [];
  Challenge? selected;
  bool isLoading = false;
  String? error;
  String? message;

  Future<void> loadJoinable() async {
    await _run(() async => joinable = await _getJoinable());
  }

  Future<void> loadMyChallenges() async {
    await _run(() async => myChallenges = await _getUserChallenges());
  }

  Future<void> loadCommunity(String communityId) async {
    await _run(() async {
      communityChallenges = await _getCommunityChallenges(communityId);
      activeChallenges = await _getActiveCommunityChallenges(communityId);
    });
  }

  Future<void> loadDetails(String challengeId) async {
    await _run(() async => selected = await _getById(challengeId));
  }

  Future<bool> joinChallenge(Challenge challenge) async {
    var success = false;
    await _run(() async {
      final result = await _join(challenge.id);
      message = result.message;
      success = true;
      joinable = joinable.where((item) => item.id != challenge.id).toList();
      await loadMyChallenges();
    });
    return success;
  }

  Future<bool> createChallenge(String communityId, Map<String, dynamic> body) async {
    var success = false;
    await _run(() async {
      final created = await _create(communityId, body);
      communityChallenges = [created, ...communityChallenges];
      activeChallenges = [created, ...activeChallenges];
      message = 'تم إنشاء التحدي بنجاح.';
      success = true;
    });
    return success;
  }

  Future<bool> updateProgress(String challengeId, double progress) async {
    var success = false;
    await _run(() async {
      final result = await _updateParticipant(challengeId, progress);
      message = result.message;
      success = true;
      await loadDetails(challengeId);
      await loadMyChallenges();
    });
    return success;
  }

  void clearFeedback() {
    error = null;
    message = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
