class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.triggeredById,
    required this.type,
    required this.targetId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String triggeredById;
  final String type;
  final String targetId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem markRead() => NotificationItem(
        id: id,
        triggeredById: triggeredById,
        type: type,
        targetId: targetId,
        content: content,
        isRead: true,
        createdAt: createdAt,
      );
}
