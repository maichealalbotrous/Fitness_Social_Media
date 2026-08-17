import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_social_app/features/community/data/community_local_storage.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/presentation/community_dependencies.dart';
import 'package:fitness_social_app/features/community/presentation/controllers/community_controller.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({this.initialCommunityId, super.key});

  final String? initialCommunityId;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final CommunityController _controller;
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _localStorage = CommunityLocalStorage();
  Uint8List? _selectedImageBytes;
  String? _selectedImageMime;
  final _requestIdController = TextEditingController();
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    _controller = CommunityDependencies.createController();
    if (widget.initialCommunityId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final id = widget.initialCommunityId!;
        await _controller.load(id);
        if (!mounted) return;
        final cached = await _localStorage.read();
        final matching = cached.where((item) => item.id == id).toList();
        if (matching.isNotEmpty) {
          _controller.restoreLocalMembership(matching.first);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _requestIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
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
          title: const Text('Community'),
          backgroundColor: const Color(0xFF050505),
          foregroundColor: Colors.white,
        ),

      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _CreateCommunityCard(
              nameController: _nameController,
              descriptionController: _descriptionController,
              imageBytes: _selectedImageBytes,
              isPrivate: _isPrivate,
              isLoading: _controller.isLoading,
              onPrivateChanged: (value) => setState(() => _isPrivate = value),
              onPickImage: _pickImage,
              onClearImage: () => setState(() {
                _selectedImageBytes = null;
                _selectedImageMime = null;
              }),
              onCreate: _create,
            ),
            const SizedBox(height: 16),
            _LookupCard(
              controller: _idController,
              isLoading: _controller.isLoading,
              onLoad: () => _controller.load(_idController.text),
            ),
            const SizedBox(height: 16),
            if (_controller.errorMessage != null)
              _Message(
                text: _controller.errorMessage!,
                color: Colors.redAccent,
              ),
            if (_controller.successMessage != null)
              _Message(
                text: _controller.successMessage!,
                color: Colors.greenAccent,
              ),
            if (_controller.community case final community?)
              _CommunityDetails(
                community: community,
                isRequestPending: _controller.isRequestPending,
                requestIdController: _requestIdController,
                isLoading: _controller.isLoading,
                onJoin: _join,
                onLeave: _leave,
                onAcceptRequest: () => _handleRequest(true),
                onRejectRequest: () => _handleRequest(false),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequest(bool accepted) async {
    final requestId = _requestIdController.text.trim();
    if (requestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل Request ID أولاً.')),
      );
      return;
    }
    await _controller.handleRequest(requestId: requestId, accepted: accepted);
    _requestIdController.clear();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageMime = image.mimeType ?? _mimeType(image.name);
    });
  }

  Future<void> _create() async {
    final imageUrl = _selectedImageBytes == null
        ? null
        : 'data:${_selectedImageMime ?? 'image/jpeg'};base64,${base64Encode(_selectedImageBytes!)}';
    await _controller.create(
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: imageUrl,
      isPrivate: _isPrivate,
    );
    final community = _controller.community;
    if (community != null) await _localStorage.save(community);
  }

  Future<void> _join() async {
    await _controller.join();
    final community = _controller.community;
    if (community != null && (community.isMember || _controller.isRequestPending)) {
      await _localStorage.save(community);
    }
  }

  Future<void> _leave() async {
    final community = _controller.community;
    if (community == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave community?'),
        content: Text('Are you sure you want to leave ${community.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _controller.leave();
    if (_controller.errorMessage == null) {
      await _localStorage.remove(community.id);
    }
  }

  String _mimeType(String name) {
    switch (name.split('.').last.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

class _CreateCommunityCard extends StatelessWidget {
  const _CreateCommunityCard({
    required this.nameController,
    required this.descriptionController,
    required this.imageBytes,
    required this.isPrivate,
    required this.isLoading,
    required this.onPrivateChanged,
    required this.onPickImage,
    required this.onClearImage,
    required this.onCreate,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Uint8List? imageBytes;
  final bool isPrivate;
  final bool isLoading;
  final ValueChanged<bool> onPrivateChanged;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Create community',
      child: Column(
        children: [
          _Input(controller: nameController, label: 'Name'),
          const SizedBox(height: 10),
          _Input(controller: descriptionController, label: 'Description', maxLines: 3),
          const SizedBox(height: 10),
          _CommunityImagePicker(
            imageBytes: imageBytes,
            onPick: onPickImage,
            onClear: onClearImage,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Private community', style: TextStyle(color: Colors.white)),
            value: isPrivate,
            onChanged: onPrivateChanged,
            activeColor: const Color(0xFFB8FF00),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading ? null : onCreate,
              child: const Text('CREATE COMMUNITY'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityImagePicker extends StatelessWidget {
  const _CommunityImagePicker({
    required this.imageBytes,
    required this.onPick,
    required this.onClear,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3B3B3B)),
        ),
        child: imageBytes == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: Colors.white70, size: 34),
                  SizedBox(height: 8),
                  Text('اختيار صورة المجتمع', style: TextStyle(color: Colors.white70)),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.memory(imageBytes!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      onPressed: onClear,
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove image',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _LookupCard extends StatelessWidget {
  const _LookupCard({required this.controller, required this.isLoading, required this.onLoad});

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Open community',
      child: Row(
        children: [
          Expanded(child: _Input(controller: controller, label: 'Community ID')),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isLoading ? null : onLoad,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}

class _CommunityDetails extends StatelessWidget {
  const _CommunityDetails({
    required this.community,
    required this.isRequestPending,
    required this.requestIdController,
    required this.isLoading,
    required this.onJoin,
    required this.onLeave,
    required this.onAcceptRequest,
    required this.onRejectRequest,
  });

  final Community community;
  final bool isRequestPending;
  final TextEditingController requestIdController;
  final bool isLoading;
  final Future<void> Function() onJoin;
  final Future<void> Function() onLeave;
  final Future<void> Function() onAcceptRequest;
  final Future<void> Function() onRejectRequest;

  @override
  Widget build(BuildContext context) {
    final action = community.isMember ? onLeave : onJoin;
    final actionLabel = community.isMember
        ? 'LEAVE COMMUNITY'
        : isRequestPending
            ? 'REQUEST PENDING'
            : 'JOIN COMMUNITY';
    return _Panel(
      title: community.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (community.imageUrl?.isNotEmpty == true)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                community.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (community.imageUrl?.isNotEmpty == true) const SizedBox(height: 12),
          if (community.description?.isNotEmpty == true)
            Text(community.description!, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(
            '${community.isPrivate ? 'Private' : 'Public'} · ${community.memberCount} members',
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 14),
          if (community.isOwner)
            const Text('You are the owner', style: TextStyle(color: Color(0xFFB8FF00))),
          if (!community.isOwner)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading || isRequestPending ? null : action,
                icon: Icon(community.isMember ? Icons.logout : isRequestPending ? Icons.hourglass_top : Icons.group_add),
                label: Text(actionLabel),
              ),
            ),
          if (community.isPrivate && !community.isMember && !community.isOwner && !isRequestPending)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'سيتم إنشاء طلب انضمام يحتاج إلى موافقة أحد المدراء.',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          if (community.isAdmin) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            const Text(
              'Manage join request',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _Input(controller: requestIdController, label: 'Request ID'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : onAcceptRequest,
                    child: const Text('ACCEPT'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : onRejectRequest,
                    child: const Text('REJECT'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Backend لا يوفر حالياً endpoint لجلب قائمة الطلبات، لذلك يجب إدخال Request ID المتاح لديك.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({required this.controller, required this.label, this.maxLines = 1});
  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1B1B1B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: TextStyle(color: color)),
      );
}
