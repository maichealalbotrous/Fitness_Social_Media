import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/presentation/community_dependencies.dart';
import 'package:fitness_social_app/features/community/presentation/controllers/community_controller.dart';

import '../challenges_dependencies.dart';
import '../controllers/challenges_controller.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});
  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  late final ChallengesController _controller;
  late final CommunityController _communityController;
  List<Community> _communities = const <Community>[];
  String? _selectedCommunityId;
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _goal = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _controller = ChallengesDependencies.createController();
    _communityController = CommunityDependencies.createController();
    _loadCommunities();
  }

  @override
  void dispose() {
    _communityController.dispose();
    _name.dispose();
    _description.dispose();
    _goal.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCommunities() async {
    await _communityController.loadMyCommunities();
    if (!mounted) return;
    setState(() {
      _communities = _communityController.myCommunities
          .where((community) => community.isOwner || community.isAdmin)
          .toList(growable: false);
      final hasSelectedCommunity = _communities.any((item) => item.id == _selectedCommunityId);
      if (!hasSelectedCommunity) {
        _selectedCommunityId = _communities.isEmpty ? null : _communities.first.id;
      }
    });
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
    final communityId = _selectedCommunityId;
    final name = _name.text.trim();
    final goal = _parseGoal(_goal.text);
    if (communityId == null || name.length < 3 || goal == null || goal <= 0 || !_end.isAfter(_start)) {
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
          _communitySelector(),
          _field(_name, 'Challenge name'),
          _field(_description, 'Description', maxLines: 3),
          _field(_goal, 'Goal (number, e.g. 3 or 3km)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
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

  Widget _communitySelector() {
    if (_communities.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(6)),
        child: Row(children: [
          const Expanded(child: Text('No communities available for creating a challenge.', style: TextStyle(color: Colors.white60))),
          IconButton(onPressed: _loadCommunities, icon: const Icon(Icons.refresh, color: Color(0xFFDFFF00))),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _communities.any((item) => item.id == _selectedCommunityId) ? _selectedCommunityId : null,
        dropdownColor: const Color(0xFF171A17),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(labelText: 'Community', labelStyle: TextStyle(color: Colors.white60), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDFFF00))), prefixIcon: Icon(Icons.groups_outlined, color: Color(0xFFDFFF00))),
        items: _communities.map((community) => DropdownMenuItem<String>(value: community.id, child: Text(community.name))).toList(),
        onChanged: (value) => setState(() => _selectedCommunityId = value),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboard}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: controller, maxLines: maxLines, keyboardType: keyboard, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white60), enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDFFF00))))));

  Widget _dateButton(String label, VoidCallback onPressed) => Padding(padding: const EdgeInsets.only(bottom: 10), child: OutlinedButton.icon(onPressed: onPressed, icon: const Icon(Icons.calendar_today, color: Color(0xFFDFFF00)), label: Text(label, style: const TextStyle(color: Colors.white)), style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.all(16), side: const BorderSide(color: Colors.white24))));

  double? _parseGoal(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    final direct = double.tryParse(normalized);
    if (direct != null) return direct;
    final numeric = RegExp(r'[-+]?\d+(?:\.\d+)?').firstMatch(normalized)?.group(0);
    return numeric == null ? null : double.tryParse(numeric);
  }

  String _format(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
