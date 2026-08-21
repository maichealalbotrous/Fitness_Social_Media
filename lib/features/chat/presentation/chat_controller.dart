import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/chat/domain/chat_entities.dart';
import 'package:fitness_social_app/features/chat/domain/chat_repository.dart';
import 'package:fitness_social_app/features/user/domain/entities/user_profile.dart';
import 'package:fitness_social_app/features/user/domain/repositories/user_repository.dart';

class ChatController extends ChangeNotifier {
  ChatController(this.repository, this.userRepository);
  final ChatRepository repository;
  final UserRepository userRepository;

  List<ChatMessage> messages = const [];
  String? otherUserId;
  UserProfile? selectedUser;
  bool isSearchingUser = false;
  String? searchError;
  bool isLoading = false;
  bool isSending = false;
  String? error;

  Future<void> searchUser(String username) async {
    final query = username.trim();
    if (query.isEmpty) return;
    isSearchingUser = true;
    searchError = null;
    notifyListeners();
    try {
      selectedUser = await userRepository.getByUsername(query);
    } on ApiException catch (exception) {
      selectedUser = null;
      searchError = exception.message;
    } catch (_) {
      selectedUser = null;
      searchError = 'Unable to find this user.';
    } finally {
      isSearchingUser = false;
      notifyListeners();
    }
  }

  void closeConversation() {
    otherUserId = null;
    messages = const [];
    error = null;
    notifyListeners();
  }

  Future<void> loadHistory(String userId) async {
    otherUserId = userId;
    await _run(() async {
      messages = await repository.getHistory(userId);
      await _markUnreadIncoming();
    });
  }

  Future<void> send(String content) async {
    final receiverId = otherUserId;
    if (receiverId == null || receiverId.isEmpty || content.trim().isEmpty) return;
    isSending = true;
    error = null;
    notifyListeners();
    try {
      final message = await repository.sendMessage(receiverId: receiverId, content: content.trim());
      messages = [...messages, message];
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (_) {
      error = 'Unable to send message.';
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(ChatMessage message) async {
    if (message.isRead) return;
    try {
      await repository.markAsRead(message.id);
      messages = messages.map((item) => item.id == message.id ? item.markRead() : item).toList(growable: false);
      notifyListeners();
    } catch (_) {
      // Keep the conversation usable if marking read fails.
    }
  }

  Future<void> _markUnreadIncoming() async {
    final unread = messages.where((item) => !item.isRead && item.receiverId != item.senderId).toList(growable: false);
    for (final message in unread) {
      await repository.markAsRead(message.id);
    }
    if (unread.isNotEmpty) {
      messages = messages.map((item) => unread.any((read) => read.id == item.id) ? item.markRead() : item).toList(growable: false);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (_) {
      error = 'Unable to load conversation.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
