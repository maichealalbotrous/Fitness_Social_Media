import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';

enum WorkoutPlanStatus { draft, pendingAcceptance, rejected, accepted, active, completed, cancelled, archived }

extension WorkoutPlanStatusX on WorkoutPlanStatus {
  static WorkoutPlanStatus fromApi(String value) => WorkoutPlanStatus.values.firstWhere((item) => item.name.toLowerCase() == value.toLowerCase(), orElse: () => WorkoutPlanStatus.draft);
  String get label => switch (this) { WorkoutPlanStatus.pendingAcceptance => 'Pending acceptance', WorkoutPlanStatus.draft => 'Draft', WorkoutPlanStatus.rejected => 'Rejected', WorkoutPlanStatus.accepted => 'Accepted', WorkoutPlanStatus.active => 'Active', WorkoutPlanStatus.completed => 'Completed', WorkoutPlanStatus.cancelled => 'Cancelled', WorkoutPlanStatus.archived => 'Archived' };
}

class PlannedExercise {
  const PlannedExercise({required this.exerciseId, required this.exerciseName, required this.order, required this.plannedSets, required this.plannedReps, required this.plannedWeight});
  final String exerciseId;
  final String exerciseName;
  final int order;
  final int plannedSets;
  final int plannedReps;
  final double plannedWeight;
}

class WorkoutDay {
  const WorkoutDay({required this.id, required this.order, required this.date, required this.name, required this.isRestDay, required this.exercises, required this.completed, this.userSessionId});
  final String id;
  final int order;
  final DateTime? date;
  final String name;
  final bool isRestDay;
  final List<PlannedExercise> exercises;
  final bool completed;
  final String? userSessionId;
}

class WorkoutPlan {
  const WorkoutPlan({required this.id, required this.ownerUserId, required this.createdByUserId, this.coachId, required this.name, required this.durationDays, required this.status, this.startDate, required this.isArchived, required this.createdAt, required this.days});
  final String id;
  final String ownerUserId;
  final String createdByUserId;
  final String? coachId;
  final String name;
  final int durationDays;
  final WorkoutPlanStatus status;
  final DateTime? startDate;
  final bool isArchived;
  final DateTime? createdAt;
  final List<WorkoutDay> days;
}

class WorkoutTemplate {
  const WorkoutTemplate({required this.id, required this.userId, required this.name, required this.durationDays, required this.isGeneral, required this.days});
  final String id;
  final String userId;
  final String name;
  final int durationDays;
  final bool isGeneral;
  final List<WorkoutDay> days;
}

class PlannedExerciseInput {
  const PlannedExerciseInput({required this.exerciseId, required this.plannedSets, required this.plannedReps, required this.plannedWeight});
  final String exerciseId;
  final int plannedSets;
  final int plannedReps;
  final double plannedWeight;
  Map<String, dynamic> toJson() => {'exerciseId': exerciseId, 'plannedSets': plannedSets, 'plannedReps': plannedReps, 'plannedWeight': plannedWeight};
}

class TemplateDayInput {
  const TemplateDayInput({required this.name, required this.isRestDay, required this.exercises});
  final String name;
  final bool isRestDay;
  final List<PlannedExerciseInput> exercises;
  Map<String, dynamic> toJson() => {'name': name, 'isRestDay': isRestDay, 'exercises': exercises.map((item) => item.toJson()).toList(growable: false)};
}

class ManualPlanDayInput {
  const ManualPlanDayInput({required this.name, required this.isRestDay, required this.exercises});
  final String name;
  final bool isRestDay;
  final List<PlannedExerciseInput> exercises;
  Map<String, dynamic> toJson() => {'name': name, 'isRestDay': isRestDay, 'exercises': exercises.map((item) => item.toJson()).toList(growable: false)};
}
