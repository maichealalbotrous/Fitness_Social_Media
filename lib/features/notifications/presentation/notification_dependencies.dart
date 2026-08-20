import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/core/storage/session_storage.dart';
import 'package:fitness_social_app/features/notifications/data/notification_remote_data_source.dart';
import 'package:fitness_social_app/features/notifications/domain/notification_repository.dart';
import 'package:fitness_social_app/features/notifications/presentation/notification_controller.dart';

class NotificationDependencies {
  const NotificationDependencies._();

  static NotificationController createController() {
    final api = ApiClient(sessionStorage: SecureSessionStorage());
    final remote = ApiNotificationRemoteDataSource(api);
    return NotificationController(NotificationRepository(remote));
  }
}
