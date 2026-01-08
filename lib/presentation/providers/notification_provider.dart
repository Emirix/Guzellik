import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

enum NotificationFilter { all, campaign, appointment }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  NotificationFilter _currentFilter = NotificationFilter.all;
  bool _isLoading = true;

  List<NotificationModel> get notifications => _getFilteredNotifications();
  NotificationFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _init();
  }

  void _init() {
    _repository.getNotificationsStream().listen((data) {
      _notifications = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<NotificationModel> _getFilteredNotifications() {
    if (_currentFilter == NotificationFilter.all) return _notifications;

    final type = _currentFilter == NotificationFilter.campaign
        ? NotificationType.campaign
        : NotificationType.appointment;

    return _notifications.where((n) => n.type == type).toList();
  }

  void setFilter(NotificationFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }
}
