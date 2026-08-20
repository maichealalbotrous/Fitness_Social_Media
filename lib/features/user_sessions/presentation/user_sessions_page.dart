import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/exercises/domain/exercise_entities.dart';
import 'package:fitness_social_app/features/exercises/presentation/exercise_controller.dart';
import 'package:fitness_social_app/features/exercises/presentation/exercise_dependencies.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';
import 'package:fitness_social_app/features/user_sessions/presentation/user_session_controller.dart';

class UserSessionsPage extends StatefulWidget {
  const UserSessionsPage({super.key, required this.controller});

  final UserSessionController controller;

  @override
  State<UserSessionsPage> createState() => _UserSessionsPageState();
}

class _UserSessionsPageState extends State<UserSessionsPage> {
  late final ExerciseController _exerciseController;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;
  String _filter = 'month';

  @override
  void initState() {
    super.initState();
    _exerciseController = ExerciseDependencies.createController();
    _loadMonth();
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    super.dispose();
  }

  Future<void> _loadMonth() {
    return widget.controller.loadByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
  }

  Future<void> _loadSelectedDay() async {
    final day = _selectedDay;
    if (day != null) {
      await widget.controller.loadByDay(day);
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select a month',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _selectedMonth = DateTime(picked.year, picked.month);
      _selectedDay = null;
      _filter = 'month';
    });
    await _loadMonth();
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select a day',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _selectedDay = picked;
      _filter = 'day';
    });
    await _loadSelectedDay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(activeSection: AppSidebarSection.workouts),
      appBar: AppBar(
        title: const Text('Training Sessions'),
        actions: [
          IconButton(
            tooltip: 'Exercises',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.exercises),
            icon: const Icon(Icons.fitness_center),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: widget.controller.isLoading
                ? null
                : (_filter == 'day' ? _loadSelectedDay : _loadMonth),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exerciseController.isLoading ? null : () => _showEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New session'),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([widget.controller, _exerciseController]),
        builder: (_, __) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'month',
                            label: Text('Month'),
                            icon: Icon(Icons.calendar_month),
                          ),
                          ButtonSegment(
                            value: 'day',
                            label: Text('Day'),
                            icon: Icon(Icons.today),
                          ),
                        ],
                        selected: {_filter},
                        onSelectionChanged: (value) {
                          final selected = value.first;
                          setState(() => _filter = selected);
                          if (selected == 'month') {
                            _loadMonth();
                          } else if (_selectedDay != null) {
                            _loadSelectedDay();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _filter == 'month' ? _pickMonth : _pickDay,
                      icon: const Icon(Icons.date_range),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _filter == 'month'
                        ? '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}'
                        : (_selectedDay == null
                            ? 'Select a day'
                            : _formatDate(_selectedDay!)),
                  ),
                ),
              ),
              if (widget.controller.isLoading)
                const LinearProgressIndicator(),
              if (widget.controller.error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.controller.error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              if (widget.controller.message != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.controller.message!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              Expanded(
                child: widget.controller.sessions.isEmpty &&
                        !widget.controller.isLoading
                    ? const Center(child: Text('No training sessions found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: widget.controller.sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            _sessionCard(widget.controller.sessions[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sessionCard(UserSession session) {
    return Card(
      child: ExpansionTile(
        title: Text(
          session.description?.trim().isNotEmpty == true
              ? session.description!
              : 'Training session',
        ),
        subtitle: Text(
          '${_formatDate(session.date)} • ${session.totalDuration} • '
          '${session.muscles.map((item) => item.label).join(', ')}',
        ),
        trailing: IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditor(session: session),
        ),
        children: session.exercises
            .map(
              (exercise) => ListTile(
                dense: true,
                title: Text(
                  '${exercise.exerciseName}${exercise.isPr ? '  • PR' : ''}',
                ),
                subtitle: Text(
                  '${exercise.sets} sets × ${exercise.reps} reps  •  '
                  '${exercise.weight.toStringAsFixed(1)} kg',
                ),
                trailing: exercise.isPr
                    ? const Icon(Icons.emoji_events_outlined, color: Colors.amber)
                    : null,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> _showEditor({UserSession? session}) async {
    if (_exerciseController.exercises.isEmpty) {
      await _exerciseController.loadAll();
    }
    if (!mounted) return;

    final description = TextEditingController(text: session?.description ?? '');
    final duration = TextEditingController(
      text: session == null ? '' : _durationMinutes(session.totalDuration).toString(),
    );
    final muscles = {...?session?.muscles};
    final records = session?.exercises
            .map(
              (item) => _DraftExercise(
                exerciseId: item.exerciseId,
                reps: item.reps,
                sets: item.sets,
                weight: item.weight,
              ),
            )
            .toList() ??
        <_DraftExercise>[];

    if (records.isEmpty && _exerciseController.exercises.isNotEmpty) {
      records.add(
        _DraftExercise(
          exerciseId: _exerciseController.exercises.first.id,
          reps: 1,
          sets: 1,
          weight: 1,
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                session == null
                    ? 'New training session'
                    : 'Edit training session',
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: description,
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      TextField(
                        controller: duration,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Target muscles'),
                      ),
                      Wrap(
                        spacing: 4,
                        children: ExerciseMuscle.values
                            .map(
                              (muscle) => FilterChip(
                                label: Text(muscle.label),
                                selected: muscles.contains(muscle),
                                onSelected: (selected) {
                                  setDialogState(() {
                                    if (selected) {
                                      muscles.add(muscle);
                                    } else {
                                      muscles.remove(muscle);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 10),
                      ...records.asMap().entries.map(
                            (entry) => _draftRow(
                              records,
                              entry.value,
                              setDialogState,
                            ),
                          ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _exerciseController.exercises.isEmpty
                              ? null
                              : () {
                                  setDialogState(() {
                                    records.add(
                                      _DraftExercise(
                                        exerciseId: _exerciseController
                                            .exercises
                                            .first
                                            .id,
                                        reps: 1,
                                        sets: 1,
                                        weight: 1,
                                      ),
                                    );
                                  });
                                },
                          icon: const Icon(Icons.add),
                          label: const Text('Add exercise'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final minutes = int.tryParse(duration.text.trim());
                    final invalid = minutes == null ||
                        minutes <= 0 ||
                        records.isEmpty ||
                        records.any(
                          (item) =>
                              item.reps <= 0 ||
                              item.sets <= 0 ||
                              item.weight <= 0,
                        );
                    if (invalid) return;

                    final inputs = records
                        .map(
                          (item) => UserExerciseInput(
                            exerciseId: item.exerciseId,
                            reps: item.reps,
                            sets: item.sets,
                            weight: item.weight,
                          ),
                        )
                        .toList(growable: false);

                    Navigator.pop(dialogContext);
                    if (session == null) {
                      await widget.controller.create(
                        description: description.text.trim().isEmpty
                            ? null
                            : description.text.trim(),
                        muscles: muscles.toList(growable: false),
                        totalDurationMinutes: minutes!,
                        exercises: inputs,
                      );
                    } else {
                      await widget.controller.update(
                        id: session.id,
                        description: description.text.trim().isEmpty
                            ? null
                            : description.text.trim(),
                        muscles: muscles.toList(growable: false),
                        totalDurationMinutes: minutes!,
                        exercises: inputs,
                      );
                    }
                  },
                  child: Text(session == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    description.dispose();
    duration.dispose();
  }

  Widget _draftRow(
    List<_DraftExercise> records,
    _DraftExercise draft,
    StateSetter setDialogState,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: draft.exerciseId,
              decoration: const InputDecoration(labelText: 'Exercise'),
              items: _exerciseController.exercises
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                setDialogState(() => draft.exerciseId = value ?? draft.exerciseId);
              },
            ),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    'Sets',
                    draft.sets,
                    (value) => setDialogState(() => draft.sets = value),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _numberField(
                    'Reps',
                    draft.reps,
                    (value) => setDialogState(() => draft.reps = value),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _doubleField(
                    'Weight',
                    draft.weight,
                    (value) => setDialogState(() => draft.weight = value),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: records.length > 1
                    ? () => setDialogState(() => records.remove(draft))
                    : null,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null) onChanged(parsed);
      },
    );
  }

  Widget _doubleField(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null) onChanged(parsed);
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _durationMinutes(String value) {
    final parts = value.split(':');
    if (parts.length == 2) {
      return (int.tryParse(parts[0]) ?? 0) * 60 +
          (int.tryParse(parts[1]) ?? 0);
    }
    return int.tryParse(value) ?? 0;
  }
}

class _DraftExercise {
  _DraftExercise({
    required this.exerciseId,
    required this.reps,
    required this.sets,
    required this.weight,
  });

  String exerciseId;
  int reps;
  int sets;
  double weight;
}
