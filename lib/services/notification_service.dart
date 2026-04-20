import '../models/notification.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    if (!FirestoreService.isAvailable) {
      return [];
    }

    return _firestoreService.getNotificationsForUser(userId);
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    if (!FirestoreService.isAvailable) {
      return 0;
    }

    return _firestoreService.getUnreadNotificationCount(userId);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    if (!FirestoreService.isAvailable) {
      return;
    }

    return _firestoreService.markNotificationAsRead(notificationId);
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    if (!FirestoreService.isAvailable) {
      return;
    }

    return _firestoreService.markAllNotificationsAsRead(userId);
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String activityId,
    required String createdByName,
    required String notificationType,
  }) async {
    if (!FirestoreService.isAvailable) {
      return;
    }

    return _firestoreService.createNotification(
      userId: userId,
      title: title,
      message: message,
      activityId: activityId,
      createdByName: createdByName,
      notificationType: notificationType,
    );
  }

  Stream<List<AppNotification>> streamNotificationsForUser(String userId) {
    if (!FirestoreService.isAvailable) {
      return const Stream<List<AppNotification>>.empty();
    }

    return _firestoreService.streamNotificationsForUser(userId);
  }

  Stream<int> streamUnreadNotificationCount(String userId) {
    if (!FirestoreService.isAvailable) {
      return const Stream<int>.empty();
    }

    return _firestoreService.streamUnreadNotificationCount(userId);
  }
}
