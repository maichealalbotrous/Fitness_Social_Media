import 'package:flutter/material.dart';
import 'package:fitness_social_app/features/notifications/domain/notification_entities.dart';
import 'package:fitness_social_app/features/notifications/presentation/notification_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/shared/app_sidebar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.controller});
  final NotificationController controller;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(activeSection: AppSidebarSection.notifications),
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: widget.controller.load),
          AnimatedBuilder(
            animation: widget.controller,
            builder: (_, __) => widget.controller.unreadCount == 0
                ? const SizedBox.shrink()
                : TextButton(onPressed: widget.controller.markAllAsRead, child: const Text('Mark all read')),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (_, __) {
          if (widget.controller.isLoading && widget.controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.controller.error != null && widget.controller.items.isEmpty) {
            return Center(child: Text(widget.controller.error!, style: const TextStyle(color: Colors.redAccent)));
          }
          if (widget.controller.items.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return RefreshIndicator(
            onRefresh: widget.controller.load,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: widget.controller.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) => _notificationTile(widget.controller.items[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _notificationTile(NotificationItem item) {
    return Card(
      color: item.isRead ? null : Theme.of(context).colorScheme.primary.withValues(alpha: .12),
      child: ListTile(
        leading: Icon(_iconFor(item.type), color: item.isRead ? Colors.white54 : Colors.amber),
        title: Text(item.content.isEmpty ? _titleFor(item.type) : item.content),
        subtitle: Text('${_titleFor(item.type)} • ${_formatDate(item.createdAt)}'),
        trailing: item.isRead ? const Icon(Icons.done, color: Colors.white38) : const Icon(Icons.fiber_new, color: Colors.amber),
        onTap: () => widget.controller.markAsRead(item),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'message':
        return Icons.mail;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  String _titleFor(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return 'New like';
      case 'comment':
        return 'New comment';
      case 'message':
        return 'New message';
      case 'follow':
        return 'New follower';
      default:
        return type.isEmpty ? 'Notification' : type;
    }
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
