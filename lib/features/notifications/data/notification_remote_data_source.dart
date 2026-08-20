import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/notifications/domain/notification_entities.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAsRead(String id);
}

class ApiNotificationRemoteDataSource implements NotificationRemoteDataSource {
  const ApiNotificationRemoteDataSource(this._api);
  final ApiClient _api;

  @override
  Future<List<NotificationItem>> getNotifications() async {
    final values = await _api.getListJson('/api/Notifications');
    return values.map(_parse).toList(growable: false);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _api.putJson('/api/Notifications/read/${Uri.encodeComponent(id)}', body: const {});
  }

  NotificationItem _parse(Map<String, dynamic> json) {
    String value(String key) => (json[key] ?? json[key[0].toUpperCase() + key.substring(1)] ?? '').toString();
    final date = DateTime.tryParse(value('createdAt')) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final rawRead = json['isRead'] ?? json['IsRead'] ?? false;
    return NotificationItem(
      id: value('id'),
      triggeredById: value('triggeredById'),
      type: value('type'),
      targetId: value('targetId'),
      content: value('content'),
      isRead: rawRead == true || rawRead.toString().toLowerCase() == 'true',
      createdAt: date,
    );
  }
}
