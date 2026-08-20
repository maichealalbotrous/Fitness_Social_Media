import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/exercises/data/exercise_remote_data_source.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_repository.dart';
import 'package:fitness_social_app/features/exercises/data/exercise_repository_impl.dart';
import 'package:fitness_social_app/features/exercises/presentation/exercise_controller.dart';

class ExerciseDependencies {
  const ExerciseDependencies._();
  static ExerciseController createController() => ExerciseController(ExerciseRepositoryImpl(ApiExerciseRemoteDataSource(ApiClient(sessionStorage: SecureSessionStorage()))));
}
