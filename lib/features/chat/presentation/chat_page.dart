import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/chat/domain/chat_entities.dart';
import 'package:fitness_social_app/features/chat/presentation/chat_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.controller});
  final ChatController controller;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _usernameController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(activeSection: AppSidebarSection.chat),
      appBar: AppBar(title: const Text('Chat')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (_, __) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Search by username'),
                      onSubmitted: (_) => _searchUser(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: widget.controller.isSearchingUser ? null : _searchUser,
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            if (widget.controller.searchError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(widget.controller.searchError!, style: const TextStyle(color: Colors.redAccent)),
              ),
            if (widget.controller.selectedUser != null)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(widget.controller.selectedUser!.username),
                  subtitle: const Text('User found'),
                  trailing: FilledButton(
                    onPressed: () => widget.controller.loadHistory(widget.controller.selectedUser!.id),
                    child: const Text('Open chat'),
                  ),
                ),
              ),
            if (widget.controller.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(widget.controller.error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            if (widget.controller.isLoading) const LinearProgressIndicator(),
            Expanded(child: _conversation()),
            _composer(),
          ],
        ),
      ),
    );
  }

  Widget _conversation() {
    if (widget.controller.otherUserId == null) {
      return const Center(child: Text('Search for a username to open a conversation.'));
    }
    if (widget.controller.messages.isEmpty && !widget.controller.isLoading) {
      return const Center(child: Text('No messages yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.controller.messages.length,
      itemBuilder: (_, index) => _messageBubble(widget.controller.messages[index]),
    );
  }

  Widget _messageBubble(ChatMessage message) {
    final mine = message.senderId != widget.controller.otherUserId;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => widget.controller.markAsRead(message),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: mine ? const Color(0xFFB9D97A) : const Color(0xFF263238),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: mine ? const Color(0xFFD9F3A3) : const Color(0xFF546E7A),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: mine ? const Color(0xFF102000) : Colors.white,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(message.sentAt),
                style: TextStyle(
                  fontSize: 11,
                  color: mine ? const Color(0xFF38521A) : const Color(0xFFCFD8DC),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _composer() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Row(
          children: [
            Expanded(child: TextField(controller: _messageController, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Write a message...'))),
            const SizedBox(width: 8),
            IconButton(onPressed: widget.controller.isSending || widget.controller.otherUserId == null ? null : _send, icon: const Icon(Icons.send)),
          ],
        ),
      ),
    );
  }

  Future<void> _searchUser() async {
    await widget.controller.searchUser(_usernameController.text);
  }

  Future<void> _send() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    await widget.controller.send(text);
    if (widget.controller.error == null) _messageController.clear();
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
