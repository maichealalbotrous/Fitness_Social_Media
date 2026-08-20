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

  Future<void> loadAll() async { await _run(() async { myApplication = await repository.getMyApplication(); trainingRequests = await repository.getTrainingRequests(); }); }
  Future<void> submitApplication(String url) async { await _run(() async { myApplication = await repository.submitApplication(url); message = 'تم إرسال طلب المدرب.'; }); }
  Future<void> submitApplicationWithImage({required List<int> bytes, required String fileName}) async {
    await _run(() async {
      final url = await repository.uploadCertification(bytes: bytes, fileName: fileName);
      myApplication = await repository.submitApplication(url);
      message = 'تم رفع الشهادة وإرسال طلب المدرب.';
    });
  }
  Future<void> loadPendingApplications() async { await _run(() async { pendingApplications = await repository.getPendingApplications(); }); }
  Future<void> reviewApplication(String id, bool approved, String? note) async { await _run(() async { await repository.reviewApplication(id, approved, note); await loadPendingApplications(); message = approved ? 'تم قبول الطلب.' : 'تم رفض الطلب.'; }); }
  Future<void> createTrainingRequest(String coachId, String? text) async { await _run(() async { await repository.createTrainingRequest(coachId, text); message = 'تم إرسال طلب التدريب.'; }); }
  Future<void> reviewTrainingRequest(String id, bool approved) async { await _run(() async { await repository.reviewTrainingRequest(id, approved); await loadAll(); message = approved ? 'تم قبول طلب التدريب.' : 'تم رفض الطلب.'; }); }
  Future<void> _run(Future<void> Function() action) async { isLoading = true; error = null; message = null; notifyListeners(); try { await action(); } on ApiException catch (e) { error = e.message; } catch (_) { error = 'تعذر تنفيذ عملية المدرب.'; } finally { isLoading = false; notifyListeners(); } }
}
