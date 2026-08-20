import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/exercises/presentation/exercise_controller.dart';
import 'package:fitness_social_app/features/exercises/presentation/exercise_dependencies.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';
import 'package:fitness_social_app/features/coach/domain/entities/coach_entities.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_controller.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_dependencies.dart';
import 'package:fitness_social_app/features/user_sessions/domain/user_session_entities.dart';
import 'package:fitness_social_app/features/workout_planning/domain/workout_planning_entities.dart';
import 'package:fitness_social_app/features/workout_planning/presentation/workout_planning_controller.dart';

class WorkoutPlanningPage extends StatefulWidget {
  const WorkoutPlanningPage({super.key, required this.controller});
  final WorkoutPlanningController controller;

  @override
  State<WorkoutPlanningPage> createState() => _WorkoutPlanningPageState();
}

class _WorkoutPlanningPageState extends State<WorkoutPlanningPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final ExerciseController _exerciseController;
  late final CoachController _coachController;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _exerciseController = ExerciseDependencies.createController();
    _coachController = CoachDependencies.createController();
    widget.controller.loadTemplates();
    widget.controller.loadPlans();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _exerciseController.dispose();
    _coachController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(activeSection: AppSidebarSection.workouts),
      appBar: AppBar(
        title: const Text('Workout Planning'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Templates'), Tab(text: 'Plans')],
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([widget.controller, _exerciseController]),
        builder: (_, __) => Column(
          children: [
            if (widget.controller.isLoading) const LinearProgressIndicator(),
            if (widget.controller.error != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(widget.controller.error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            if (widget.controller.message != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(widget.controller.message!, style: const TextStyle(color: Colors.green)),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [_templates(), _plans()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tabs.index == 0 ? _createTemplateDialog() : _createPlanDialog(),
        icon: const Icon(Icons.add),
        label: Text(_tabs.index == 0 ? 'Template' : 'Plan'),
      ),
    );
  }

  Widget _templates() {
    if (widget.controller.templates.isEmpty) {
      return const Center(child: Text('No workout templates found.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.controller.templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = widget.controller.templates[index];
        return Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text('${item.durationDays} days • ${item.isGeneral ? 'General' : 'Personal'} • ${item.days.length} days'),
            trailing: IconButton(
              icon: const Icon(Icons.archive_outlined),
              onPressed: () => widget.controller.archiveTemplate(item.id),
            ),
          ),
        );
      },
    );
  }

  Widget _plans() {
    if (widget.controller.plans.isEmpty) {
      return const Center(child: Text('No workout plans found.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.controller.plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _planCard(widget.controller.plans[index]),
    );
  }

  Widget _planCard(WorkoutPlan plan) {
    final actions = <Widget>[];
    if (plan.status == WorkoutPlanStatus.pendingAcceptance) {
      actions.add(TextButton(onPressed: () => widget.controller.sendPlan(plan.id), child: const Text('Send')));
      actions.add(TextButton(onPressed: () => widget.controller.acceptPlan(plan.id), child: const Text('Accept')));
      actions.add(TextButton(onPressed: () => widget.controller.rejectPlan(plan.id), child: const Text('Reject')));
    }
    if (plan.status == WorkoutPlanStatus.draft || plan.status == WorkoutPlanStatus.accepted) {
      actions.add(TextButton(onPressed: () => _startPlan(plan), child: const Text('Start')));
    }
    return Card(
      child: ExpansionTile(
        title: Text(plan.name),
        subtitle: Text('${plan.durationDays} days • ${plan.status.label}'),
        children: [
          if (actions.isNotEmpty) Wrap(spacing: 6, children: actions),
          ...plan.days.map(
            (day) => ListTile(
              title: Text('${day.order}. ${day.name}'),
              subtitle: Text(day.isRestDay ? 'Rest day' : '${day.exercises.length} exercises'),
              trailing: day.completed
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : day.isRestDay
                      ? null
                      : IconButton(icon: const Icon(Icons.done), onPressed: () => _completeDay(plan, day)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createTemplateDialog() async {
    final name = TextEditingController();
    final duration = TextEditingController(text: '7');
    final days = [const TemplateDayInput(name: 'Day 1', isRestDay: false, exercises: [])];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create template'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration days')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final value = int.tryParse(duration.text) ?? 0;
              if (name.text.trim().isEmpty || value <= 0) return;
              Navigator.pop(dialogContext);
              await widget.controller.createTemplate(name: name.text.trim(), durationDays: value, isGeneral: false, days: days);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    name.dispose();
    duration.dispose();
  }

  Future<void> _createPlanDialog() async {
    await _coachController.loadApprovedParticipants();
    if (!mounted) return;
    final name = TextEditingController();
    final duration = TextEditingController(text: '7');
    String? selectedParticipantId;
    final selectedTemplates = <String>{};
    final days = [const ManualPlanDayInput(name: 'Day 1', isRestDay: false, exercises: [])];
    String? validationError;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create plan'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (validationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(validationError!, style: const TextStyle(color: Colors.redAccent)),
                ),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration days')),
              if (_coachController.approvedParticipants.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedParticipantId,
                  decoration: const InputDecoration(labelText: 'Participant'),
                  hint: const Text('Choose a participant you train'),
                  items: _coachController.approvedParticipants
                      .map((participant) => DropdownMenuItem<String>(
                            value: participant.id,
                            child: Text(participant.username),
                          ))
                      .toList(growable: false),
                  onChanged: (value) => setDialogState(() => selectedParticipantId = value),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No approved participants found. Leave this empty for a personal plan.'),
                ),
              if (widget.controller.templates.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Align(alignment: Alignment.centerLeft, child: Text('Use templates')),
                ...widget.controller.templates.map(
                  (item) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name),
                    value: selectedTemplates.contains(item.id),
                    onChanged: (value) => setDialogState(() {
                      if (value == true) {
                        selectedTemplates.add(item.id);
                      } else {
                        selectedTemplates.remove(item.id);
                      }
                    }),
                  ),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final value = int.tryParse(duration.text.trim()) ?? 0;
                if (name.text.trim().isEmpty || value <= 0) {
                  setDialogState(() {
                    validationError = name.text.trim().isEmpty
                        ? 'Please enter a plan name.'
                        : 'Duration must be greater than zero.';
                  });
                  return;
                }
                final planDays = selectedTemplates.isNotEmpty
                    ? const <ManualPlanDayInput>[]
                    : days;
                await widget.controller.createPlan(
                  name: name.text.trim(),
                  durationDays: value,
                  ownerUserId: selectedParticipantId,
                  templateIds: selectedTemplates.toList(growable: false),
                  days: planDays,
                );
                if (!mounted || widget.controller.error != null) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    duration.dispose();
  }

  Future<void> _startPlan(WorkoutPlan plan) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date != null) await widget.controller.startPlan(plan.id, date);
  }

  Future<void> _completeDay(WorkoutPlan plan, WorkoutDay day) async {
    final duration = TextEditingController(text: '30');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Complete ${day.name}'),
        content: TextField(controller: duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration minutes')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final minutes = int.tryParse(duration.text) ?? 0;
              if (minutes <= 0) return;
              Navigator.pop(dialogContext);
              await widget.controller.completeDay(planId: plan.id, dayId: day.id, totalDurationMinutes: minutes, description: day.name, muscles: const [], exercises: day.exercises.map((item) => UserExerciseInput(exerciseId: item.exerciseId, reps: item.plannedReps, sets: item.plannedSets, weight: item.plannedWeight)).toList(growable: false));
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    duration.dispose();
  }
}
