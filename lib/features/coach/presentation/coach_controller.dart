import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/coach/domain/coach_contracts.dart';
import 'package:fitness_social_app/features/coach/domain/entities/coach_entities.dart';

class CoachController extends ChangeNotifier {
  CoachController(this.repository);

  final CoachRepository repository;
  bool isLoading = false;
  String? error;
  String? message;
  CoachApplication? myApplication;
  List<CoachApplication> pendingApplications = const [];
  List<TrainingRequest> trainingRequests = const [];
  List<CoachProfile> coaches = const [];
  List<CoachProfile> topRatedCoaches = const [];
  List<CoachProfile> participantCoaches = const [];
  bool canManageTrainingRequests = false;

  Future<void> loadAll() async {
    await _run(() async {
      try {
        myApplication = await repository.getMyApplication();
      } on ApiException catch (exception) {
        if (exception.statusCode != 404) rethrow;
        myApplication = null;
      }
      try {
        trainingRequests = await repository.getTrainingRequests();
        canManageTrainingRequests = true;
      } on ApiException catch (exception) {
        if (exception.statusCode != 401 && exception.statusCode != 403) rethrow;
        trainingRequests = const [];
        canManageTrainingRequests = false;
      }
    });
  }

  Future<void> submitApplication(String url) async {
    await _run(() async {
      myApplication = await repository.submitApplication(url);
      message = 'تم إرسال طلب المدرب.';
    });
  }

  Future<void> submitApplicationWithImage({required List<int> bytes, required String fileName}) async {
    await _run(() async {
      final url = await repository.uploadCertification(bytes: bytes, fileName: fileName);
      myApplication = await repository.submitApplication(url);
      message = 'تم رفع الشهادة وإرسال طلب المدرب.';
    });
  }

  Future<void> loadPendingApplications() async {
    await _run(() async => pendingApplications = await repository.getPendingApplications());
  }

  Future<void> reviewApplication(String id, bool approved, String? note) async {
    await _run(() async {
      await repository.reviewApplication(id, approved, note);
      await loadPendingApplications();
      message = approved ? 'تم قبول الطلب.' : 'تم رفض الطلب.';
    });
  }

  Future<void> loadCoaches() async => _run(() async { coaches = await repository.getAllCoaches(); });
  Future<void> loadTopRatedCoaches() async => _run(() async { topRatedCoaches = await repository.getTopRatedCoaches(); });
  Future<void> searchCoaches(String name) async => _run(() async { coaches = await repository.findCoachesByName(name); });
  Future<void> loadParticipantCoaches(String participantId) async => _run(() async { participantCoaches = await repository.getParticipantCoaches(participantId); });
  Future<void> loadMyCoaches() async => _run(() async {
    final requests = await repository.getTrainingRequests();
    final approvedCoachIds = requests
        .where((request) => request.status.toLowerCase() == 'approved')
        .map((request) => request.coachId)
        .toSet();
    final allCoaches = await repository.getAllCoaches();
    participantCoaches = allCoaches.where((coach) => approvedCoachIds.contains(coach.userId)).toList(growable: false);
  });
  Future<void> rateCoach(String coachId, int rating) async => _run(() async { await repository.rateCoach(coachId, rating); message = 'تم إرسال التقييم.'; });

  Future<void> createTrainingRequest(String coachId, String? text) async {
    await _run(() async {
      await repository.createTrainingRequest(coachId, text);
      message = 'تم إرسال طلب التدريب.';
    });
  }

  Future<void> reviewTrainingRequest(String id, bool approved) async {
    await _run(() async {
      await repository.reviewTrainingRequest(id, approved);
      trainingRequests = trainingRequests.where((request) => request.id != id).toList(growable: false);
      message = approved ? 'تم قبول طلب التدريب.' : 'تم رفض طلب التدريب.';
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();
    try {
      await action();
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (_) {
      error = 'تعذر تنفيذ عملية المدرب.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
