import '../../domain/entities/challenge.dart';

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.creatorId,
    required super.communityId,
    required super.name,
    required super.description,
    required super.startDate,
    required super.endDate,
    required super.goal,
    super.progress,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    String value(List<String> keys) {
      for (final key in keys) {
        final item = json[key];
        if (item != null && item.toString().isNotEmpty) return item.toString();
      }
      return '';
    }

    DateTime date(List<String> keys) {
      final raw = value(keys);
      return DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
    }

    double number(List<String> keys) {
      for (final key in keys) {
        final item = json[key];
        if (item is num) return item.toDouble();
        final parsed = double.tryParse(item?.toString() ?? '');
        if (parsed != null) return parsed;
      }
      return 0;
    }

    return ChallengeModel(
      id: value(const ['id', 'Id']),
      creatorId: value(const ['creatorId', 'CreatorId']),
      communityId: value(const ['communityId', 'CommunityId']),
      name: value(const ['name', 'Name']),
      description: value(const ['description', 'Description']),
      startDate: date(const ['startDate', 'StartDate']),
      endDate: date(const ['endDate', 'EndDate']),
      goal: number(const ['goal', 'Goal']),
      progress: number(const ['progress', 'Progress', 'goalParticipation', 'GoalParticipation']),
    );
  }
}
