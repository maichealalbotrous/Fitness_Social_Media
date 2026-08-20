import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/exercises/presentation/exercise_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key, required this.controller});
  final ExerciseController controller;

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  ExerciseMuscle? _filterMuscle;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    widget.controller.loadAll();
  }

  Future<void> _applyFilter() async {
    if (_filterType == 'all' || _filterMuscle == null) {
      await widget.controller.loadAll();
    } else if (_filterType == 'main') {
      await widget.controller.filterByMainMuscle(_filterMuscle!);
    } else {
      await widget.controller.filterBySecondaryMuscle(_filterMuscle!);
    }
  }

  void _showDetails(Exercise exercise) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: Text(
          '${exercise.description}\n\nMain muscle: ${exercise.mainMuscle.label}\nSecondary muscles: ${exercise.secondaryMuscles.map((item) => item.label).join(', ')}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(activeSection: AppSidebarSection.workouts),
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: widget.controller.isLoading ? null : widget.controller.loadAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (_, __) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterType,
                      decoration: const InputDecoration(labelText: 'Filter by'),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All exercises')),
                        DropdownMenuItem(value: 'main', child: Text('Main muscle')),
                        DropdownMenuItem(value: 'secondary', child: Text('Secondary muscle')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterType = value ?? 'all';
                          if (_filterType == 'all') _filterMuscle = null;
                        });
                        _applyFilter();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<ExerciseMuscle>(
                      value: _filterMuscle,
                      decoration: const InputDecoration(labelText: 'Muscle'),
                      items: ExerciseMuscle.values
                          .map((muscle) => DropdownMenuItem(value: muscle, child: Text(muscle.label)))
                          .toList(growable: false),
                      onChanged: _filterType == 'all'
                          ? null
                          : (value) {
                              setState(() => _filterMuscle = value);
                              _applyFilter();
                            },
                    ),
                  ),
                ],
              ),
            ),
            if (widget.controller.isLoading) const LinearProgressIndicator(),
            if (widget.controller.error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(widget.controller.error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            Expanded(
              child: widget.controller.exercises.isEmpty && !widget.controller.isLoading
                  ? const Center(child: Text('No exercises found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.controller.exercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final exercise = widget.controller.exercises[index];
                        return Card(
                          child: ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(
                              '${exercise.description}\nMain: ${exercise.mainMuscle.label}\nSecondary: ${exercise.secondaryMuscles.map((item) => item.label).join(', ')}',
                            ),
                            isThreeLine: true,
                            onTap: () => _showDetails(exercise),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
