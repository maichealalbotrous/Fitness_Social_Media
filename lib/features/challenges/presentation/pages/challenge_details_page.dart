import 'package:flutter/material.dart';

import '../../domain/entities/challenge.dart';
import '../challenges_dependencies.dart';
import '../controllers/challenges_controller.dart';

class ChallengeDetailsPage extends StatefulWidget {
  const ChallengeDetailsPage({required this.challenge, this.onJoin, super.key});
  final Challenge challenge;
  final Future<bool> Function(Challenge challenge)? onJoin;

  @override
  State<ChallengeDetailsPage> createState() => _ChallengeDetailsPageState();
}

class _ChallengeDetailsPageState extends State<ChallengeDetailsPage> {
  late final ChallengesController _controller;
  final _progressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ChallengesDependencies.createController()..loadDetails(widget.challenge.id);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final success = widget.onJoin != null ? await widget.onJoin!(widget.challenge) : await _controller.joinChallenge(widget.challenge);
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _updateProgress() async {
    final value = double.tryParse(_progressController.text.trim());
    final current = _controller.selected ?? widget.challenge;
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid positive number.')));
      return;
    }
    if (current.progress >= current.goal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have already reached the challenge goal and cannot record additional progress.')));
      return;
    }
    if (value > current.goal) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Progress cannot exceed the goal of ${current.goal.toStringAsFixed(1)}.')));
      return;
    }
    final success = await _controller.updateProgress(widget.challenge.id, value);
    if (success && mounted && value >= current.goal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Congratulations, you have fully reached the challenge goal.')));
    }
    if (mounted && _controller.error == null) _progressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final challenge = _controller.selected ?? widget.challenge;
        return Scaffold(
        backgroundColor: const Color(0xFF030403),
        appBar: AppBar(backgroundColor: const Color(0xFF030403), foregroundColor: Colors.white, title: const Text('Challenge details'), leading: const BackButton()),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text(challenge.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(challenge.description, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 24),
          _Metric(label: 'Start', value: _date(challenge.startDate)),
          _Metric(label: 'End', value: _date(challenge.endDate)),
          _Metric(label: 'Goal', value: challenge.goal.toStringAsFixed(1)),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: challenge.progressRatio, minHeight: 10, backgroundColor: Colors.white12, color: const Color(0xFFDFFF00)),
          const SizedBox(height: 8),
          Text('${challenge.progress.toStringAsFixed(1)} / ${challenge.goal.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 28),
          if (widget.onJoin != null) FilledButton.icon(onPressed: _controller.isLoading ? null : _join, icon: const Icon(Icons.add_task), label: const Text('Join challenge')),
          if (widget.onJoin == null) ...[
            const Text('Add progress', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            TextField(controller: _progressController, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Amount completed', labelStyle: TextStyle(color: Colors.white60), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDFFF00))))),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _controller.isLoading ? null : _updateProgress, icon: const Icon(Icons.trending_up), label: const Text('Update progress')),
          ],
          if (_controller.error != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_controller.error!, style: const TextStyle(color: Colors.redAccent))),
          if (_controller.message != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_controller.message!, style: const TextStyle(color: Color(0xFFDFFF00)))),
                ]),
        );
      },
    );
  }
  String _date(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Text('$label: ', style: const TextStyle(color: Colors.white54)), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]));
}
