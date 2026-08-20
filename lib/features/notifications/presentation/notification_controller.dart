import 'package:flutter/foundation.dart';
import 'package:fitness_social_app/core/network/api_client.dart';
import 'package:fitness_social_app/features/notifications/domain/notification_entities.dart';
import 'package:fitness_social_app/features/notifications/domain/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  NotificationController(this.repository);
  final NotificationRepository repository;

  List<NotificationItem> items = const [];
  bool isLoading = false;
  String? error;

  int get unreadCount => items.where((item) => !item.isRead).length;

  Future<void> load() async {
    await _run(() async => items = await repository.getNotifications());
  }

  Future<void> markAsRead(NotificationItem item) async {
    if (item.isRead) return;
    await _run(() async {
      await repository.markAsRead(item.id);
      items = items.map((current) => current.id == item.id ? current.markRead() : current).toList(growable: false);
    });
  }

  Future<void> markAllAsRead() async {
    final unread = items.where((item) => !item.isRead).toList(growable: false);
    for (final item in unread) {
      await markAsRead(item);
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
      error = 'Unable to load notifications.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
