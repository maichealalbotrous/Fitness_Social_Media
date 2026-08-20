import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/notifications/data/notification_remote_data_source.dart';
import 'package:fitness_social_app/features/notifications/domain/notification_repository.dart';
import 'package:fitness_social_app/features/notifications/presentation/notification_controller.dart';

class NotificationDependencies {
  const NotificationDependencies._();

  static NotificationController createController() {
    final remote = ApiNotificationRemoteDataSource(ApiClient.instance);
    return NotificationController(NotificationRepository(remote));
  }
}
