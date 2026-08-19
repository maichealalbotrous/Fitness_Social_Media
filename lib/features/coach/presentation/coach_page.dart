import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_controller.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key, required this.controller});
  final CoachController controller;
  @override State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final _coachId = TextEditingController();
  final _message = TextEditingController();
  @override void dispose() { _coachId.dispose(); _message.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF030403),
    appBar: AppBar(title: const Text('Coach'), backgroundColor: Colors.black, foregroundColor: Colors.white),
    body: AnimatedBuilder(animation: widget.controller, builder: (_, __) => ListView(padding: const EdgeInsets.all(18), children: [
      _panel('Request a coach', Column(children: [
        const Text('Send a training request to an approved coach.', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 14),
        TextField(controller: _coachId, style: const TextStyle(color: Colors.white), decoration: _decoration('Coach ID')),
        const SizedBox(height: 10),
        TextField(controller: _message, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: _decoration('Message (optional)')),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: widget.controller.isLoading ? null : () => widget.controller.createTrainingRequest(_coachId.text.trim(), _message.text.trim()), child: const Text('SEND TRAINING REQUEST'))),
      ])),
      if (widget.controller.error != null) Text(widget.controller.error!, style: const TextStyle(color: Colors.redAccent)),
      if (widget.controller.message != null) Text(widget.controller.message!, style: const TextStyle(color: Colors.greenAccent)),
    ])),
  );
  Widget _panel(String title, Widget child) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 14), child]));
  InputDecoration _decoration(String label) => InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF1B1B1B), border: const OutlineInputBorder());
}
