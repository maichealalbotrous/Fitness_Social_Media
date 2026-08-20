import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/chat/domain/chat_entities.dart';

abstract interface class ChatRemoteDataSource {
  Future<ChatMessage> sendMessage({required String receiverId, required String content});
  Future<List<ChatMessage>> getHistory(String otherUserId);
  Future<void> markAsRead(String messageId);
}

class ApiChatRemoteDataSource implements ChatRemoteDataSource {
  const ApiChatRemoteDataSource(this._api);
  final ApiClient _api;
  static const _base = '/api/Chat';

  @override
  Future<ChatMessage> sendMessage({required String receiverId, required String content}) async {
    return _parse(await _api.postJson('$_base/send', body: {'receiverId': receiverId, 'content': content}));
  }

  @override
  Future<List<ChatMessage>> getHistory(String otherUserId) async {
    final values = await _api.getListJson('$_base/history/${Uri.encodeComponent(otherUserId)}');
    return values.map(_parse).toList(growable: false);
  }

  @override
  Future<void> markAsRead(String messageId) async {
    await _api.putJson('$_base/read/${Uri.encodeComponent(messageId)}', body: const {});
  }

  ChatMessage _parse(Map<String, dynamic> json) {
    String value(String key) => (json[key] ?? json[key[0].toUpperCase() + key.substring(1)] ?? '').toString();
    final rawRead = json['isRead'] ?? json['IsRead'] ?? false;
    return ChatMessage(
      id: value('id'),
      senderId: value('senderId'),
      receiverId: value('receiverId'),
      content: value('content'),
      isRead: rawRead == true || rawRead.toString().toLowerCase() == 'true',
      sentAt: DateTime.tryParse(value('sentAt')) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
