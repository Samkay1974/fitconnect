import 'dart:async';

import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../services/notification_service.dart';
import '../utils/error_mapper.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<AppNotification>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  NotificationProvider(this._notificationService);

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _notificationsSubscription?.cancel();
    await _unreadCountSubscription?.cancel();

    _notificationsSubscription = _notificationService
        .streamNotificationsForUser(userId)
        .listen(
          (notifications) {
            _notifications = notifications;
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object e) {
            _error = ErrorMapper.toMessage(e);
            _isLoading = false;
            notifyListeners();
          },
        );

    _unreadCountSubscription = _notificationService
        .streamUnreadNotificationCount(userId)
        .listen(
          (count) {
            _unreadCount = count;
            notifyListeners();
          },
          onError: (Object e) {
            _error = ErrorMapper.toMessage(e);
            notifyListeners();
          },
        );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        if (_unreadCount > 0) {
          _unreadCount--;
        }
      }

      notifyListeners();
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllNotificationsAsRead(userId);

      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      notifyListeners();
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }
}
