import 'package:flutter/material.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/physical_data/domain/physical_data_entities.dart';
import 'package:fitness_social_app/features/physical_data/presentation/physical_data_controller.dart';
import 'package:fitness_social_app/features/user/data/local_profile_storage.dart';
import 'package:fitness_social_app/features/user/presentation/controllers/local_profile_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_routes.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';

class PhysicalDataPage extends StatefulWidget {
  const PhysicalDataPage({super.key, required this.controller});
  final PhysicalDataController controller;
  @override
  State<PhysicalDataPage> createState() => _PhysicalDataPageState();
}

class _PhysicalDataPageState extends State<PhysicalDataPage> {
  LocalProfileController? _profile;
  final _height = TextEditingController();
  final _weight = TextEditingController();
  PhysicalSex? _sex;
  DateTime? _birthday;
  bool _heightPrivate = true;
  bool _weightsPrivate = true;
  bool _sexPrivate = true;
  bool _birthdayPrivate = true;
  bool _recordsPrivate = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final profileStorage = await LocalProfileStorage.create();
    final profile = LocalProfileController(sessionStorage: SecureSessionStorage(), profileStorage: profileStorage);
    await profile.load();
    if (!mounted) { profile.dispose(); return; }
    setState(() => _profile = profile);
    final userId = profile.userId;
    if (userId == null || userId.isEmpty) {
      setState(() => widget.controller.error = 'Unable to determine the current user.');
      widget.controller.notifyListeners();
      return;
    }
    await widget.controller.load(userId);
    _fill(widget.controller.data);
  }

  void _fill(UserPhysicalData? data) {
    if (data == null || !mounted) return;
    setState(() {
      _height.text = data.heightCm?.toString() ?? '';
      _sex = data.sex;
      _birthday = data.birthday;
      _heightPrivate = data.heightIsPrivate;
      _weightsPrivate = data.weightsIsPrivate;
      _sexPrivate = data.sexIsPrivate;
      _birthdayPrivate = data.birthdayIsPrivate;
      _recordsPrivate = data.personalRecordsIsPrivate;
    });
  }

  @override
  void dispose() {
    _profile?.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = _profile?.userId;
    final height = double.tryParse(_height.text.trim());
    if (userId == null || userId.isEmpty || (height != null && height <= 0)) return;
    await widget.controller.update(userId: userId, heightCm: height, sex: _sex, birthday: _birthday, heightIsPrivate: _heightPrivate, weightsIsPrivate: _weightsPrivate, sexIsPrivate: _sexPrivate, birthdayIsPrivate: _birthdayPrivate, personalRecordsIsPrivate: _recordsPrivate);
  }

  Future<void> _addWeight() async {
    final userId = _profile?.userId;
    final weight = double.tryParse(_weight.text.trim());
    if (userId == null || userId.isEmpty || weight == null || weight <= 0) return;
    await widget.controller.addWeight(userId: userId, weightKg: weight);
    if (widget.controller.error == null) _weight.clear();
  }

  Future<void> _pickBirthday() async {
    final selected = await showDatePicker(context: context, firstDate: DateTime(1900), lastDate: DateTime.now(), initialDate: _birthday ?? DateTime(2000));
    if (selected != null) setState(() => _birthday = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(activeSection: AppSidebarSection.profile),
      appBar: AppBar(
        title: const Text('Physical Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.feed);
            }
          },
        ),
      ),
      body: AnimatedBuilder(animation: widget.controller, builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
        if (widget.controller.isLoading) const LinearProgressIndicator(),
        if (widget.controller.error != null) Text(widget.controller.error!, style: const TextStyle(color: Colors.redAccent)),
        if (widget.controller.message != null) Text(widget.controller.message!, style: const TextStyle(color: Colors.green)),
        _section('Body information', [
          TextField(controller: _height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height (cm)')),
          DropdownButtonFormField<PhysicalSex>(value: _sex, decoration: const InputDecoration(labelText: 'Gender'), items: PhysicalSex.values.map((sex) => DropdownMenuItem(value: sex, child: Text(sex.label))).toList(growable: false), onChanged: (value) => setState(() => _sex = value)),
          ListTile(contentPadding: EdgeInsets.zero, title: Text(_birthday == null ? 'Birthday' : '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}'), trailing: const Icon(Icons.calendar_month), onTap: _pickBirthday),
          FilledButton.icon(onPressed: widget.controller.isLoading ? null : _save, icon: const Icon(Icons.save_outlined), label: const Text('Save physical data')),
        ]),
        _section('Privacy settings', [
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Keep height private'), value: _heightPrivate, onChanged: (value) => setState(() => _heightPrivate = value)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Keep weights private'), value: _weightsPrivate, onChanged: (value) => setState(() => _weightsPrivate = value)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Keep sex private'), value: _sexPrivate, onChanged: (value) => setState(() => _sexPrivate = value)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Keep birthday private'), value: _birthdayPrivate, onChanged: (value) => setState(() => _birthdayPrivate = value)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Keep personal records private'), value: _recordsPrivate, onChanged: (value) => setState(() => _recordsPrivate = value)),
        ]),
        _section('Weight history', [
          Row(children: [Expanded(child: TextField(controller: _weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)'))), const SizedBox(width: 10), FilledButton(onPressed: widget.controller.isLoading ? null : _addWeight, child: const Text('Add'))]),
          const SizedBox(height: 8),
          if (widget.controller.data?.weights.isEmpty ?? true) const Text('No weight entries yet.'),
          ...?(widget.controller.data?.weights.reversed.map((entry) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.monitor_weight_outlined), title: Text('${entry.weightKg.toStringAsFixed(1)} kg'), subtitle: Text(entry.addedAt.toLocal().toString().split('.').first))).toList()),
        ]),
        _section('Personal records', [
          if (widget.controller.data?.personalRecords.isEmpty ?? true) const Text('No personal records yet.'),
          ...?(widget.controller.data?.personalRecords.map((record) => ListTile(contentPadding: EdgeInsets.zero, title: Text(record.exerciseName), subtitle: Text('${record.maxWeightKg.toStringAsFixed(1)} kg • ${record.date.toLocal().toString().split('.').first}'))).toList()),
        ]),
      ])),
    );
  }

  Widget _section(String title, List<Widget> children) => Card(margin: const EdgeInsets.only(bottom: 16), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12), ...children])));
}
