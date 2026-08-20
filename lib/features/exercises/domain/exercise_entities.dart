enum ExerciseMuscle {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  abdominals,
  glutes,
  quadriceps,
  hamstrings,
  calves,
  fullBody,
}

extension ExerciseMuscleX on ExerciseMuscle {
  String get apiValue {
    switch (this) {
      case ExerciseMuscle.fullBody:
        return 'FullBody';
      case ExerciseMuscle.abdominals:
        return 'Abdominals';
      case ExerciseMuscle.quadriceps:
        return 'Quadriceps';
      case ExerciseMuscle.hamstrings:
        return 'Hamstrings';
      default:
        final value = name;
        return value[0].toUpperCase() + value.substring(1);
    }
  }

  String get label => apiValue;

  static ExerciseMuscle? fromApi(String? value) {
    if (value == null) return null;
    final normalized = value.replaceAll('_', '').replaceAll(' ', '').toLowerCase();
    for (final muscle in ExerciseMuscle.values) {
      if (muscle.apiValue.toLowerCase() == normalized) return muscle;
    }
    return null;
  }
}

class Exercise {
  const Exercise({required this.id, required this.name, required this.description, required this.mainMuscle, required this.secondaryMuscles});
  final String id;
  final String name;
  final String description;
  final ExerciseMuscle mainMuscle;
  final List<ExerciseMuscle> secondaryMuscles;
}
