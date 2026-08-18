class Challenge {
  const Challenge({
    required this.id,
    required this.creatorId,
    required this.communityId,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.goal,
    this.progress = 0,
  });

  final String id;
  final String creatorId;
  final String communityId;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double goal;
  final double progress;

  bool get isActive {
    final now = DateTime.now().toUtc();
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }

  double get progressRatio {
    if (goal <= 0) return 0;
    final ratio = progress / goal;
    return ratio.clamp(0, 1).toDouble();
  }
}

class ChallengeActionResult {
  const ChallengeActionResult({required this.message});
  final String message;
}
