import 'package:fitness_social_app/features/physical_data/data/physical_data_remote_data_source.dart';
import 'package:fitness_social_app/features/physical_data/domain/physical_data_entities.dart';
import 'package:fitness_social_app/features/physical_data/domain/physical_data_repository.dart';

class PhysicalDataRepositoryImpl implements PhysicalDataRepository {
  const PhysicalDataRepositoryImpl(this.remote);
  final PhysicalDataRemoteDataSource remote;
  @override Future<UserPhysicalData> get(String userId) => remote.get(userId);
  @override Future<UserPhysicalData> update({required String userId, required double? heightCm, required PhysicalSex? sex, required DateTime? birthday, required bool heightIsPrivate, required bool weightsIsPrivate, required bool sexIsPrivate, required bool birthdayIsPrivate, required bool personalRecordsIsPrivate}) => remote.update(userId: userId, heightCm: heightCm, sex: sex, birthday: birthday, heightIsPrivate: heightIsPrivate, weightsIsPrivate: weightsIsPrivate, sexIsPrivate: sexIsPrivate, birthdayIsPrivate: birthdayIsPrivate, personalRecordsIsPrivate: personalRecordsIsPrivate);
  @override Future<UserPhysicalData> addWeight({required String userId, required double weightKg}) => remote.addWeight(userId: userId, weightKg: weightKg);
}
