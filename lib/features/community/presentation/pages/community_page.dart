import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/community/domain/entities/community.dart';
import 'package:fitness_social_app/features/community/presentation/community_dependencies.dart';
import 'package:fitness_social_app/features/community/presentation/controllers/community_controller.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final CommunityController _controller;
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _requestIdController = TextEditingController();
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    _controller = CommunityDependencies.createController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _requestIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
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
              imageUrlController: _imageUrlController,
              isPrivate: _isPrivate,
              isLoading: _controller.isLoading,
              onPrivateChanged: (value) => setState(() => _isPrivate = value),
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
                onJoin: _controller.join,
                onLeave: _controller.leave,
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

  Future<void> _create() async {
    await _controller.create(
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      isPrivate: _isPrivate,
    );
  }
}

class _CreateCommunityCard extends StatelessWidget {
  const _CreateCommunityCard({
    required this.nameController,
    required this.descriptionController,
    required this.imageUrlController,
    required this.isPrivate,
    required this.isLoading,
    required this.onPrivateChanged,
    required this.onCreate,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController imageUrlController;
  final bool isPrivate;
  final bool isLoading;
  final ValueChanged<bool> onPrivateChanged;
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
          _Input(controller: imageUrlController, label: 'Image URL (optional)'),
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
