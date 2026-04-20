import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/activity.dart';
import '../models/activity_type.dart';
import '../models/notification.dart';
import '../models/user.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static bool get isAvailable => Firebase.apps.isNotEmpty;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _activities =>
      _firestore.collection('activities');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Future<User?> getUserById(String userId) async {
    if (!isAvailable) {
      return null;
    }

    final snapshot = await _users.doc(userId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return User.fromJson(snapshot.data()!);
  }

  Future<User?> getUserByEmail(String email) async {
    if (!isAvailable) {
      return null;
    }

    final snapshot = await _users
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return User.fromJson(snapshot.docs.first.data());
  }

  Future<void> saveUser(User user) async {
    if (!isAvailable) {
      return;
    }

    await _users.doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  Future<List<Activity>> getActivities() async {
    if (!isAvailable) {
      return [];
    }

    final snapshot = await _activities.get();
    final activities = _activitiesFromSnapshot(snapshot.docs);
    activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return activities;
  }

  Future<Activity?> getActivityById(String activityId) async {
    if (!isAvailable) {
      return null;
    }

    final snapshot = await _activities.doc(activityId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return Activity.fromJson(snapshot.data()!);
  }

  Future<List<Activity>> searchActivities(String query) async {
    if (!isAvailable) {
      return [];
    }

    final lowerQuery = query.toLowerCase();
    final snapshot = await _activities.get();

    return snapshot.docs
        .map((doc) => Activity.fromJson(doc.data()))
        .where(
          (activity) =>
              activity.title.toLowerCase().contains(lowerQuery) ||
              activity.location.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  Future<List<Activity>> getActivitiesByType(ActivityType type) async {
    if (!isAvailable) {
      return [];
    }

    final typeValue = type.toString().split('.').last;
    final snapshot = await _activities.where('type', isEqualTo: typeValue).get();
    final activities = _activitiesFromSnapshot(snapshot.docs);
    activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return activities;
  }

  Future<List<Activity>> getActivitiesCreatedBy(String userId) async {
    if (!isAvailable) {
      return [];
    }

    final snapshot = await _activities.where('createdBy', isEqualTo: userId).get();
    final activities = _activitiesFromSnapshot(snapshot.docs);
    activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return activities;
  }

  Future<List<Activity>> getActivitiesJoinedBy(String userId) async {
    if (!isAvailable) {
      return [];
    }

    final snapshot =
        await _activities.where('participantIds', arrayContains: userId).get();
    final activities = _activitiesFromSnapshot(snapshot.docs);
    activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return activities;
  }

  Stream<List<Activity>> streamActivities() {
    if (!isAvailable) {
      return const Stream<List<Activity>>.empty();
    }

    return _activities.snapshots().map((snapshot) {
      final activities = _activitiesFromSnapshot(snapshot.docs);
      activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return activities;
    });
  }

  List<Activity> _activitiesFromSnapshot(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final activities = <Activity>[];

    for (final doc in docs) {
      try {
        final data = <String, dynamic>{...doc.data(), 'id': doc.id};
        activities.add(Activity.fromJson(data, documentId: doc.id));
      } catch (_) {
        // Skip malformed legacy records so one bad doc does not blank the list.
      }
    }

    return activities;
  }

  Future<Activity> saveActivity(Activity activity) async {
    if (!isAvailable) {
      return activity;
    }

    await _activities.doc(activity.id).set(activity.toJson());
    return activity;
  }

  Future<Activity> updateActivity(Activity activity) async {
    if (!isAvailable) {
      return activity;
    }

    await _activities.doc(activity.id).set(activity.toJson(), SetOptions(merge: true));
    return activity;
  }

  Future<void> deleteActivity(String activityId) async {
    if (!isAvailable) {
      return;
    }

    await _activities.doc(activityId).delete();
  }

  Future<List<String>> getAllUserIds() async {
    if (!isAvailable) {
      return [];
    }

    final snapshot = await _users.get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<Activity> joinActivity({
    required String activityId,
    required String userId,
  }) async {
    if (!isAvailable) {
      throw StateError('Firestore is not available');
    }

    final docRef = _activities.doc(activityId);
    await docRef.update({
      'participantIds': FieldValue.arrayUnion([userId]),
    });

    final updated = await docRef.get();
    if (!updated.exists || updated.data() == null) {
      throw Exception('Activity not found');
    }

    return Activity.fromJson(updated.data()!);
  }

  Future<Activity> leaveActivity({
    required String activityId,
    required String userId,
  }) async {
    if (!isAvailable) {
      throw StateError('Firestore is not available');
    }

    final docRef = _activities.doc(activityId);
    await docRef.update({
      'participantIds': FieldValue.arrayRemove([userId]),
    });

    final updated = await docRef.get();
    if (!updated.exists || updated.data() == null) {
      throw Exception('Activity not found');
    }

    return Activity.fromJson(updated.data()!);
  }

  // Notification queries
  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    if (!isAvailable) {
      return [];
    }

    final snapshot = await _notifications.where('userId', isEqualTo: userId).get();

    final notifications = snapshot.docs
        .map((doc) => AppNotification.fromJson(doc.data()))
        .toList();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  Stream<List<AppNotification>> streamNotificationsForUser(String userId) {
    if (!isAvailable) {
      return const Stream<List<AppNotification>>.empty();
    }

    return _notifications.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data()))
          .toList();
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    if (!isAvailable) {
      return 0;
    }

    final snapshot = await _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Stream<int> streamUnreadNotificationCount(String userId) {
    if (!isAvailable) {
      return const Stream<int>.empty();
    }

    return _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    if (!isAvailable) {
      return;
    }

    await _notifications.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    if (!isAvailable) {
      return;
    }

    final snapshot = await _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String activityId,
    required String createdByName,
    required String notificationType,
  }) async {
    if (!isAvailable) {
      return;
    }

    final notification = AppNotification(
      userId: userId,
      title: title,
      message: message,
      activityId: activityId,
      createdByName: createdByName,
      notificationType: notificationType,
    );

    await _notifications.doc(notification.id).set(notification.toJson());
  }
}
