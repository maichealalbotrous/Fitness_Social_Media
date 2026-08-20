import 'package:fitness_social_app/features/chat/data/chat_remote_data_source.dart';
import 'package:fitness_social_app/features/chat/domain/chat_entities.dart';

class ChatRepository {
  const ChatRepository(this.remote);
  final ChatRemoteDataSource remote;

  Future<ChatMessage> sendMessage({required String receiverId, required String content}) => remote.sendMessage(receiverId: receiverId, content: content);
  Future<List<ChatMessage>> getHistory(String otherUserId) => remote.getHistory(otherUserId);
  Future<void> markAsRead(String messageId) => remote.markAsRead(messageId);
}
