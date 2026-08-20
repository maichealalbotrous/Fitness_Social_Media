import 'package:fitness_social_app/features/coach/domain/entities/coach_entities.dart';
import 'package:fitness_social_app/features/coach/data/datasources/coach_remote_data_source.dart';

class CoachRepository {
  const CoachRepository(this.remote);
  final CoachRemoteDataSource remote;
  Future<String> uploadCertification({required List<int> bytes, required String fileName}) => remote.uploadCertification(bytes: bytes, fileName: fileName);
  Future<CoachApplication> submitApplication(String url) => remote.submitApplication(url);
  Future<CoachApplication?> getMyApplication() => remote.getMyApplication();
  Future<List<CoachApplication>> getPendingApplications() => remote.getPendingApplications();
  Future<CoachApplication> reviewApplication(String id, bool approved, String? note) => remote.reviewApplication(id, approved: approved, reviewNote: note);
  Future<List<CoachProfile>> getAllCoaches() => remote.getAllCoaches();
  Future<List<CoachProfile>> getTopRatedCoaches() => remote.getTopRatedCoaches();
  Future<List<CoachProfile>> findCoachesByName(String name) => remote.findCoachesByName(name);
  Future<List<CoachProfile>> getParticipantCoaches(String participantId) => remote.getParticipantCoaches(participantId);
  Future<void> rateCoach(String coachId, int rating) => remote.rateCoach(coachId, rating);
  Future<TrainingRequest> createTrainingRequest(String coachId, String? message) => remote.createTrainingRequest(coachId: coachId, message: message);
  Future<List<TrainingRequest>> getTrainingRequests() => remote.getTrainingRequests();
  Future<TrainingRequest> reviewTrainingRequest(String id, bool approved) => remote.reviewTrainingRequest(id, approved: approved);
  Future<CoachUser> getUser(String userId) => remote.getUser(userId);
}
