import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitness_social_app/features/coach/presentation/coach_controller.dart';
import 'package:fitness_social_app/features/user/presentation/user_dependencies.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/user_controller.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key, required this.controller});
  final CoachController controller;
  @override State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final _coachId = TextEditingController();
  final _imagePicker = ImagePicker();
  Uint8List? _certificationBytes;
  String? _certificationFileName;
  final _message = TextEditingController();
  late final UserController _userController;
  final Map<String, String> _athleteNames = <String, String>{};

  @override
  void initState() {
    super.initState();
    _userController = UserDependencies.createController();
    _loadCoachData();
  }

  @override
  void dispose() {
    _coachId.dispose();
    _message.dispose();
    _userController.dispose();
    super.dispose();
  }

  Future<void> _loadCoachData() async {
    await widget.controller.loadAll();
    if (!mounted) return;
    for (final request in widget.controller.trainingRequests) {
      final profile = await _userController.loadById(request.athleteId);
      if (profile != null && mounted) {
        _athleteNames[request.athleteId] = profile.username;
      }
    }
    if (mounted) setState(() {});
  }
  Future<void> _pickCertification() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600, maxHeight: 1600);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() { _certificationBytes = bytes; _certificationFileName = file.name; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF030403),
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed('/feed');
          }
        },
      ),
      title: const Text('Coach'),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    body: AnimatedBuilder(animation: widget.controller, builder: (_, __) => ListView(padding: const EdgeInsets.all(18), children: [
      _panel('Become a coach', Column(children: [
        if (_certificationBytes != null) ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_certificationBytes!, height: 150, width: double.infinity, fit: BoxFit.cover)),
        if (_certificationBytes != null) const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: widget.controller.isLoading ? null : _pickCertification, icon: const Icon(Icons.upload_file), label: Text(_certificationFileName ?? 'Choose certification image'))),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: widget.controller.isLoading || _certificationBytes == null ? null : () => widget.controller.submitApplicationWithImage(bytes: _certificationBytes!, fileName: _certificationFileName ?? 'certification.jpg'), child: const Text('UPLOAD AND SUBMIT APPLICATION'))),
        if (widget.controller.myApplication != null) Align(alignment: Alignment.centerLeft, child: Text('Your application: ${widget.controller.myApplication!.status}', style: const TextStyle(color: Colors.amber))),
      ])),
      _panel('Request a coach', Column(children: [
        TextField(controller: _coachId, style: const TextStyle(color: Colors.white), decoration: _decoration('Coach ID')),
        const SizedBox(height: 10),
        TextField(controller: _message, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: _decoration('Message (optional)')),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: widget.controller.isLoading ? null : () => widget.controller.createTrainingRequest(_coachId.text.trim(), _message.text.trim()), child: const Text('SEND TRAINING REQUEST'))),
      ])),
      _panel('Training requests', !widget.controller.canManageTrainingRequests
          ? const Text('This section is available after your Coach application is approved.', style: TextStyle(color: Colors.white54))
          : widget.controller.trainingRequests.isEmpty
              ? const Text('No training requests.', style: TextStyle(color: Colors.white54))
              : Column(children: widget.controller.trainingRequests.map((request) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(_athleteNames[request.athleteId] ?? 'Loading user...', style: const TextStyle(color: Colors.white)),
        subtitle: Text(request.message ?? request.status, style: const TextStyle(color: Colors.white60)),
        trailing: request.status.toLowerCase() == 'pending' ? Wrap(children: [
          IconButton(onPressed: () => widget.controller.reviewTrainingRequest(request.id!, true), icon: const Icon(Icons.check, color: Colors.green)),
          IconButton(onPressed: () => widget.controller.reviewTrainingRequest(request.id!, false), icon: const Icon(Icons.close, color: Colors.red)),
        ]) : Text(request.status, style: const TextStyle(color: Colors.white54)),
      )).toList(growable: false)),),
      if (widget.controller.error != null) Text(widget.controller.error!, style: const TextStyle(color: Colors.redAccent)),
      if (widget.controller.message != null) Text(widget.controller.message!, style: const TextStyle(color: Colors.greenAccent)),
    ])),
  );

  Widget _panel(String title, Widget child) => Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 14), child]));
  InputDecoration _decoration(String label) => InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF1B1B1B), border: const OutlineInputBorder());
}
