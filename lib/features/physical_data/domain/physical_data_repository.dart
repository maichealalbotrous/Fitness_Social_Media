import 'package:fitness_social_app/features/physical_data/domain/physical_data_entities.dart';

abstract interface class PhysicalDataRepository {
  Future<UserPhysicalData> get(String userId);
  Future<UserPhysicalData> update({required String userId, required double? heightCm, required PhysicalSex? sex, required DateTime? birthday, required bool heightIsPrivate, required bool weightsIsPrivate, required bool sexIsPrivate, required bool birthdayIsPrivate, required bool personalRecordsIsPrivate});
  Future<UserPhysicalData> addWeight({required String userId, required double weightKg});
}
