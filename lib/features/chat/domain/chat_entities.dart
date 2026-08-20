class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  ChatMessage markRead() => ChatMessage(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        isRead: true,
        sentAt: sentAt,
      );
}
