import 'package:fitness_social_app/features/notifications/data/notification_remote_data_source.dart';
import 'package:fitness_social_app/features/notifications/domain/notification_entities.dart';

class NotificationRepository {
  const NotificationRepository(this.remote);
  final NotificationRemoteDataSource remote;

  Future<List<NotificationItem>> getNotifications() => remote.getNotifications();
  Future<void> markAsRead(String id) => remote.markAsRead(id);
}
