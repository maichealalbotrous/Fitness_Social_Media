import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/coach/data/datasources/coach_remote_data_source.dart';
import 'package:fitness_social_app/features/coach/domain/coach_contracts.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_controller.dart';
class CoachDependencies { const CoachDependencies._(); static CoachController createController() => CoachController(CoachRepository(ApiCoachRemoteDataSource(ApiClient(sessionStorage: SecureSessionStorage())))); }
