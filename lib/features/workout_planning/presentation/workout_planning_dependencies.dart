import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/workout_planning/data/workout_planning_remote_data_source.dart';
import 'package:fitness_social_app/features/workout_planning/data/workout_planning_repository_impl.dart';
import 'package:fitness_social_app/features/workout_planning/presentation/workout_planning_controller.dart';

class WorkoutPlanningDependencies {
  const WorkoutPlanningDependencies._();
  static WorkoutPlanningController createController() => WorkoutPlanningController(WorkoutPlanningRepositoryImpl(ApiWorkoutPlanningRemoteDataSource(ApiClient(sessionStorage: SecureSessionStorage()))));
}
