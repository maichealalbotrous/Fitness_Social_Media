import 'package:flutter/material.dart';

import '../challenges_dependencies.dart';
import '../controllers/challenges_controller.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});
  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  late final ChallengesController _controller;
  final _communityId = TextEditingController();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _goal = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _controller = ChallengesDependencies.createController();
  }

  @override
  void dispose() {
    _communityId.dispose();
    _name.dispose();
    _description.dispose();
    _goal.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final picked = await showDatePicker(context: context, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 3650)), initialDate: start ? _start : _end);
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start.add(const Duration(days: 1));
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    final communityId = _communityId.text.trim();
    final name = _name.text.trim();
    final goal = double.tryParse(_goal.text.trim());
    if (communityId.isEmpty || name.length < 3 || goal == null || goal <= 0 || !_end.isAfter(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete all fields with valid values.')));
      return;
    }
    final success = await _controller.createChallenge(communityId, {
      'name': name,
      'description': _description.text.trim(),
      'startDate': _start.toUtc().toIso8601String(),
      'endDate': _end.toUtc().toIso8601String(),
      'goal': goal,
    });
    if (success && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFF030403),
        appBar: AppBar(backgroundColor: const Color(0xFF030403), foregroundColor: Colors.white, title: const Text('Create challenge'), leading: const BackButton()),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          _field(_communityId, 'Community ID'),
          _field(_name, 'Challenge name'),
          _field(_description, 'Description', maxLines: 3),
          _field(_goal, 'Goal', keyboard: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 14),
          _dateButton('Start: ${_format(_start)}', () => _pickDate(start: true)),
          _dateButton('End: ${_format(_end)}', () => _pickDate(start: false)),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: _controller.isLoading ? null : _submit, icon: const Icon(Icons.flag_outlined), label: const Text('Create challenge')),
          if (_controller.error != null) Padding(padding: const EdgeInsets.only(top: 14), child: Text(_controller.error!, style: const TextStyle(color: Colors.redAccent))),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboard}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: controller, maxLines: maxLines, keyboardType: keyboard, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white60), enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDFFF00))))));

  Widget _dateButton(String label, VoidCallback onPressed) => Padding(padding: const EdgeInsets.only(bottom: 10), child: OutlinedButton.icon(onPressed: onPressed, icon: const Icon(Icons.calendar_today, color: Color(0xFFDFFF00)), label: Text(label, style: const TextStyle(color: Colors.white)), style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.all(16), side: const BorderSide(color: Colors.white24))));

  String _format(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
