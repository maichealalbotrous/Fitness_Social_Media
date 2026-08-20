import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/physical_data/domain/physical_data_entities.dart';
import 'package:fitness_social_app/features/physical_data/domain/physical_data_repository.dart';

class PhysicalDataController extends ChangeNotifier {
  PhysicalDataController(this.repository);
  final PhysicalDataRepository repository;
  UserPhysicalData? data;
  bool isLoading = false;
  String? error;
  String? message;

  Future<void> load(String userId) async => _run(() async { data = await repository.get(userId); });
  Future<void> update({required String userId, required double? heightCm, required PhysicalSex? sex, required DateTime? birthday, required bool heightIsPrivate, required bool weightsIsPrivate, required bool sexIsPrivate, required bool birthdayIsPrivate, required bool personalRecordsIsPrivate}) async => _run(() async { data = await repository.update(userId: userId, heightCm: heightCm, sex: sex, birthday: birthday, heightIsPrivate: heightIsPrivate, weightsIsPrivate: weightsIsPrivate, sexIsPrivate: sexIsPrivate, birthdayIsPrivate: birthdayIsPrivate, personalRecordsIsPrivate: personalRecordsIsPrivate); message = 'تم تحديث بياناتك البدنية.'; });
  Future<void> addWeight({required String userId, required double weightKg}) async => _run(() async { data = await repository.addWeight(userId: userId, weightKg: weightKg); message = 'تم تسجيل الوزن.'; });

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();
    try { await action(); } on ApiException catch (exception) { error = exception.message; } catch (_) { error = 'تعذر تنفيذ عملية البيانات البدنية.'; } finally { isLoading = false; notifyListeners(); }
  }
}
