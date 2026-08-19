class CoachApplication {
  const CoachApplication({required this.id, required this.userId, required this.certificationUrl, required this.status, this.reviewNote, required this.submittedAt, this.reviewedAt});
  final String? id;
  final String userId;
  final String certificationUrl;
  final String status;
  final String? reviewNote;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
}

class TrainingRequest {
  const TrainingRequest({required this.id, required this.athleteId, required this.coachId, this.message, required this.status, required this.createdAt, this.reviewedAt});
  final String? id;
  final String athleteId;
  final String coachId;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
}

class CoachUser {
  const CoachUser({required this.id, required this.username});
  final String id;
  final String username;
}
