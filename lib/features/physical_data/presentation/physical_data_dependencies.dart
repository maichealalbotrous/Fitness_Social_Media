import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/physical_data/data/physical_data_remote_data_source.dart';
import 'package:fitness_social_app/features/physical_data/data/physical_data_repository_impl.dart';
import 'package:fitness_social_app/features/physical_data/presentation/physical_data_controller.dart';

class PhysicalDataDependencies {
  const PhysicalDataDependencies._();
  static PhysicalDataController createController() => PhysicalDataController(PhysicalDataRepositoryImpl(ApiPhysicalDataRemoteDataSource(ApiClient(sessionStorage: SecureSessionStorage()))));
}
