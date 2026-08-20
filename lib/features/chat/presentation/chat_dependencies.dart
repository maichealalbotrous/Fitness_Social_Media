import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/chat/data/chat_remote_data_source.dart';
import 'package:fitness_social_app/features/chat/domain/chat_repository.dart';
import 'package:fitness_social_app/features/chat/presentation/chat_controller.dart';

class ChatDependencies {
  const ChatDependencies._();

  static ChatController createController() {
    final api = ApiClient(sessionStorage: SecureSessionStorage());
    return ChatController(ChatRepository(ApiChatRemoteDataSource(api)));
  }
}
