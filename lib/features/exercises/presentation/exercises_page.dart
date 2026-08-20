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
    final muscle = _filterMuscle;
    if (_filterType == 'all' || muscle == null) {
      await widget.controller.loadAll();
    } else if (_filterType == 'main') {
      await widget.controller.filterByMainMuscle(muscle);
    } else {
      await widget.controller.filterBySecondaryMuscle(muscle);
    }
  }

  Future<void> _showEditor({Exercise? exercise}) async {
    final name = TextEditingController(text: exercise?.name);
    final description = TextEditingController(text: exercise?.description);
    var main = exercise?.mainMuscle ?? ExerciseMuscle.chest;
    var secondary = {...?exercise?.secondaryMuscles};
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: Text(exercise == null ? 'Create exercise' : 'Edit exercise'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          DropdownButtonFormField<ExerciseMuscle>(value: main, decoration: const InputDecoration(labelText: 'Main muscle'), items: ExerciseMuscle.values.map((muscle) => DropdownMenuItem(value: muscle, child: Text(muscle.label))).toList(), onChanged: (value) => setDialogState(() => main = value ?? main)),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: const Text('Secondary muscles')),
          Wrap(spacing: 4, children: ExerciseMuscle.values.map((muscle) => FilterChip(label: Text(muscle.label), selected: secondary.contains(muscle), onSelected: (selected) => setDialogState(() => selected ? secondary.add(muscle) : secondary.remove(muscle)))).toList()),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            if (name.text.trim().length < 2 || description.text.trim().length < 2 || secondary.isEmpty) return;
            Navigator.pop(context);
            if (exercise == null) {
              await widget.controller.create(name: name.text.trim(), description: description.text.trim(), mainMuscle: main, secondaryMuscles: secondary.toList());
            } else {
              await widget.controller.update(id: exercise.id, name: name.text.trim(), description: description.text.trim(), mainMuscle: main, secondaryMuscles: secondary.toList());
            }
          }, child: Text(exercise == null ? 'Create' : 'Save')),
        ],
      )),
    );
    name.dispose();
    description.dispose();
  }

  Future<void> _confirmDelete(Exercise exercise) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Delete exercise?'), content: Text(exercise.name), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])) ?? false;
    if (confirmed) await widget.controller.delete(exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(activeSection: AppSidebarSection.workouts),
      appBar: AppBar(title: const Text('Exercises'), actions: [IconButton(onPressed: widget.controller.isLoading ? null : () => widget.controller.loadAll(), icon: const Icon(Icons.refresh)), IconButton(onPressed: () => _showEditor(), icon: const Icon(Icons.add))]),
      body: AnimatedBuilder(animation: widget.controller, builder: (_, __) {
        return Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Row(children: [
            Expanded(child: DropdownButtonFormField<String>(value: _filterType, decoration: const InputDecoration(labelText: 'Filter by'), items: const [DropdownMenuItem(value: 'all', child: Text('All exercises')), DropdownMenuItem(value: 'main', child: Text('Main muscle')), DropdownMenuItem(value: 'secondary', child: Text('Secondary muscle'))], onChanged: (value) { setState(() { _filterType = value ?? 'all'; if (_filterType == 'all') _filterMuscle = null; }); _applyFilter(); })),
            const SizedBox(width: 10),
            Expanded(child: DropdownButtonFormField<ExerciseMuscle>(value: _filterMuscle, decoration: const InputDecoration(labelText: 'Muscle'), items: ExerciseMuscle.values.map((muscle) => DropdownMenuItem(value: muscle, child: Text(muscle.label))).toList(), onChanged: _filterType == 'all' ? null : (value) { setState(() => _filterMuscle = value); _applyFilter(); })),
          ])),
          if (widget.controller.isLoading) const LinearProgressIndicator(),
          if (widget.controller.error != null) Padding(padding: const EdgeInsets.all(12), child: Text(widget.controller.error!, style: const TextStyle(color: Colors.redAccent))),
          if (widget.controller.message != null) Padding(padding: const EdgeInsets.all(12), child: Text(widget.controller.message!, style: const TextStyle(color: Colors.green))),
          Expanded(child: widget.controller.exercises.isEmpty && !widget.controller.isLoading ? const Center(child: Text('No exercises found.')) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: widget.controller.exercises.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, index) { final exercise = widget.controller.exercises[index]; return Card(child: ListTile(title: Text(exercise.name), subtitle: Text('${exercise.description}\nMain: ${exercise.mainMuscle.label}\nSecondary: ${exercise.secondaryMuscles.map((item) => item.label).join(', ')}'), isThreeLine: true, onTap: () => showDialog(context: context, builder: (context) => AlertDialog(title: Text(exercise.name), content: Text(exercise.description), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])), trailing: Wrap(children: [IconButton(tooltip: 'Edit', onPressed: () => _showEditor(exercise: exercise), icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: 'Delete', onPressed: () => _confirmDelete(exercise), icon: const Icon(Icons.delete_outline, color: Colors.redAccent))]))); }))
        ]);
      }),
    );
  }
}
