import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_repository.dart';

class ExerciseController extends ChangeNotifier {
  ExerciseController(this.repository);
  final ExerciseRepository repository;
  List<Exercise> exercises = const [];
  List<String> muscles = const [];
  bool isLoading = false;
  String? error;
  String? message;

  Future<void> loadAll() async => _run(() async { exercises = await repository.getAll(); muscles = await repository.getMuscles(); });
  Future<void> filterByMainMuscle(ExerciseMuscle muscle) async => _run(() async { exercises = await repository.getByMainMuscle(muscle); });
  Future<void> filterBySecondaryMuscle(ExerciseMuscle muscle) async => _run(() async { exercises = await repository.getBySecondaryMuscle(muscle); });
  Future<Exercise?> getById(String id) async { try { return await repository.getById(id); } on ApiException catch (exception) { error = exception.message; notifyListeners(); return null; } }
  Future<void> create({required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles}) async => _run(() async { await repository.create(name: name, description: description, mainMuscle: mainMuscle, secondaryMuscles: secondaryMuscles); message = 'تم إنشاء التمرين.'; exercises = await repository.getAll(); });
  Future<void> update({required String id, required String name, required String description, required ExerciseMuscle mainMuscle, required List<ExerciseMuscle> secondaryMuscles}) async => _run(() async { await repository.update(id: id, name: name, description: description, mainMuscle: mainMuscle, secondaryMuscles: secondaryMuscles); message = 'تم تحديث التمرين.'; exercises = await repository.getAll(); });
  Future<void> delete(String id) async => _run(() async { await repository.delete(id); message = 'تم حذف التمرين.'; exercises = exercises.where((exercise) => exercise.id != id).toList(growable: false); });

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    message = null;
    notifyListeners();
    try { await action(); } on ApiException catch (exception) { error = exception.message; } catch (_) { error = 'تعذر تنفيذ عملية التمرين.'; } finally { isLoading = false; notifyListeners(); }
  }
}
