import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_constants.dart';
import '../models/activity.dart';
import '../models/activity_type.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class ActivityService {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  final List<Activity> _mockActivities = [];

  ActivityService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _mockActivities.addAll([
      Activity(
        title: 'Football Match at Accra Sports Stadium',
        description: 'Friendly football match. All levels welcome!',
        type: ActivityType.football,
        location: 'Accra Sports Stadium',
        dateTime: now.add(const Duration(days: 2)),
        maxParticipants: 22,
        participantIds: [],
        createdBy: 'user1',
      ),
      Activity(
        title: 'Morning Aerobics Session',
        description: 'Wake up and exercise with us! Bring your energy!',
        type: ActivityType.aerobics,
        location: 'Osu Recreation Center',
        dateTime: now.add(const Duration(days: 1)),
        maxParticipants: 30,
        participantIds: [],
        createdBy: 'user2',
      ),
      Activity(
        title: 'Weekend Jogging at Labadi Beach',
        description: 'Scenic beach jog. Pace varies, all welcome.',
        type: ActivityType.jogging,
        location: 'Labadi Beach',
        dateTime: now.add(const Duration(days: 3)),
        maxParticipants: 50,
        participantIds: [],
        createdBy: 'user3',
      ),
      Activity(
        title: 'Yoga & Meditation Class',
        description: 'Relaxing yoga session. Beginners welcome!',
        type: ActivityType.yoga,
        location: 'Cantonments Wellness Center',
        dateTime: now.add(const Duration(days: 1)),
        maxParticipants: 20,
        participantIds: [],
        createdBy: 'user4',
      ),
      Activity(
        title: 'Gym Training Session',
        description: 'Weight training and cardio workout.',
        type: ActivityType.gym,
        location: 'FitHub Gym, East Legon',
        dateTime: now.add(const Duration(days: 2)),
        maxParticipants: 15,
        participantIds: [],
        createdBy: 'user5',
      ),
      Activity(
        title: 'Basketball Game',
        description: 'Friendly basketball match at local court.',
        type: ActivityType.basketball,
        location: 'Tema Sports Complex',
        dateTime: now.add(const Duration(days: 4)),
        maxParticipants: 12,
        participantIds: [],
        createdBy: 'user6',
      ),
    ]);
  }

  Future<List<Activity>> getActivities() async {
    if (!FirestoreService.isAvailable) {
      return _mockActivities;
    }

    return _firestoreService.getActivities();
  }

  Future<Activity> getActivityById(String id) async {
    if (!FirestoreService.isAvailable) {
      return _mockActivities.firstWhere(
        (a) => a.id == id,
        orElse: () => throw Exception('Activity not found'),
      );
    }

    final activity = await _firestoreService.getActivityById(id);
    if (activity == null) {
      throw Exception('Activity not found');
    }
    return activity;
  }

  Future<List<Activity>> searchActivities(String query) async {
    if (!FirestoreService.isAvailable) {
      return _mockActivities
          .where(
            (a) =>
                a.title.toLowerCase().contains(query.toLowerCase()) ||
                a.location.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    return _firestoreService.searchActivities(query);
  }

  Future<List<Activity>> filterByType(ActivityType type) async {
    if (!FirestoreService.isAvailable) {
      return _mockActivities.where((a) => a.type == type).toList();
    }

    return _firestoreService.getActivitiesByType(type);
  }

  Future<Activity> createActivity({
    required String title,
    required String description,
    String? imageFilePath,
    String? imageUrl,
    required ActivityType type,
    required String location,
    required DateTime dateTime,
    required int maxParticipants,
    required String userId,
    String? createdByName,
  }) async {
    final resolvedImageUrl = await _resolveImageUrl(
      userId: userId,
      existingImageUrl: imageUrl,
      imageFilePath: imageFilePath,
    );

    final newActivity = Activity(
      title: title,
      description: description,
      imageUrl: resolvedImageUrl,
      type: type,
      location: location,
      dateTime: dateTime,
      maxParticipants: maxParticipants,
      createdBy: userId,
    );

    if (!FirestoreService.isAvailable) {
      _mockActivities.add(newActivity);
      return newActivity;
    }

    final savedActivity = await _firestoreService.saveActivity(newActivity);

    // Don't block the create flow while fan-out notifications are written.
    unawaited(
      _dispatchActivityCreatedNotifications(
        savedActivity: savedActivity,
        creatorUserId: userId,
        createdByName: createdByName,
        title: title,
      ),
    );

    return savedActivity;
  }

  Future<void> _dispatchActivityCreatedNotifications({
    required Activity savedActivity,
    required String creatorUserId,
    required String title,
    String? createdByName,
  }) async {
    List<String> recipients = <String>[creatorUserId];
    try {
      final allUserIds = await _firestoreService.getAllUserIds();
      if (allUserIds.isNotEmpty) {
        recipients = allUserIds;
      }
    } catch (_) {
      // Fall back to creator-only notification if user listing is restricted.
    }

    await Future.wait(
      recipients.map((recipientId) async {
        try {
          await _notificationService.createNotification(
            userId: recipientId,
            title: 'New Activity',
            message: '${createdByName ?? 'A user'} created: $title',
            activityId: savedActivity.id,
            createdByName: createdByName ?? 'User',
            notificationType: 'activity_created',
          );
        } catch (_) {
          // Continue creating remaining notifications if one write fails.
        }
      }),
    );
  }

  Future<Activity> updateActivity(
    Activity activity, {
    String? imageFilePath,
  }) async {
    final resolvedImageUrl = await _resolveImageUrl(
      userId: activity.createdBy,
      existingImageUrl: activity.imageUrl,
      imageFilePath: imageFilePath,
    );

    final updatedActivity = activity.copyWith(imageUrl: resolvedImageUrl);

    if (!FirestoreService.isAvailable) {
      final index = _mockActivities.indexWhere((a) => a.id == updatedActivity.id);
      if (index == -1) {
        throw Exception('Activity not found');
      }
      _mockActivities[index] = updatedActivity;
      return updatedActivity;
    }

    return _firestoreService.updateActivity(updatedActivity);
  }

  Stream<List<Activity>> streamActivities() {
    if (!FirestoreService.isAvailable) {
      return Stream<List<Activity>>.value(List<Activity>.from(_mockActivities));
    }
    return _firestoreService.streamActivities();
  }

  Future<void> deleteActivity(String activityId) async {
    if (!FirestoreService.isAvailable) {
      _mockActivities.removeWhere((a) => a.id == activityId);
      return;
    }

    await _firestoreService.deleteActivity(activityId);
  }

  Future<Activity> joinActivity({
    required String activityId,
    required String userId,
  }) async {
    if (!FirestoreService.isAvailable) {
      final index = _mockActivities.indexWhere((a) => a.id == activityId);
      if (index == -1) {
        throw Exception('Activity not found');
      }

      final activity = _mockActivities[index];
      if (!activity.participantIds.contains(userId)) {
        final updatedParticipants = [...activity.participantIds, userId];
        _mockActivities[index] = activity.copyWith(
          participantIds: updatedParticipants,
          isJoined: true,
        );
      }
      return _mockActivities[index];
    }

    return _firestoreService.joinActivity(
      activityId: activityId,
      userId: userId,
    );
  }

  Future<Activity> leaveActivity({
    required String activityId,
    required String userId,
  }) async {
    if (!FirestoreService.isAvailable) {
      final index = _mockActivities.indexWhere((a) => a.id == activityId);
      if (index == -1) {
        throw Exception('Activity not found');
      }

      final activity = _mockActivities[index];
      final updatedParticipants = activity.participantIds
          .where((id) => id != userId)
          .toList();
      _mockActivities[index] = activity.copyWith(
        participantIds: updatedParticipants,
        isJoined: false,
      );
      return _mockActivities[index];
    }

    return _firestoreService.leaveActivity(
      activityId: activityId,
      userId: userId,
    );
  }

  Future<List<Activity>> getUserCreatedActivities(String userId) async {
    if (!FirestoreService.isAvailable) {
      return _mockActivities.where((a) => a.createdBy == userId).toList();
    }

    return _firestoreService.getActivitiesCreatedBy(userId);
  }

  Future<List<Activity>> getUserJoinedActivities(String userId) async {
    if (!FirestoreService.isAvailable) {
      return _mockActivities
          .where((a) => a.participantIds.contains(userId))
          .toList();
    }

    final activities = await _firestoreService.getActivitiesJoinedBy(userId);
    return activities
        .map((activity) => activity.copyWith(isJoined: true))
        .toList();
  }

  Future<void> createUpcomingEventReminders(String userId) async {
    if (!FirestoreService.isAvailable) {
      return;
    }

    final now = DateTime.now();
    final reminderWindowEnd = now.add(const Duration(hours: 24));

    final createdActivities = await _firestoreService.getActivitiesCreatedBy(userId);
    final joinedActivities = await _firestoreService.getActivitiesJoinedBy(userId);
    final allActivities = <String, Activity>{
      for (final activity in createdActivities) activity.id: activity,
      for (final activity in joinedActivities) activity.id: activity,
    }.values.toList();

    final existingNotifications = await _notificationService.getNotificationsForUser(userId);
    final reminderKeys = existingNotifications
        .where((n) => n.notificationType == 'event_reminder_24h')
        .map((n) => n.activityId)
        .toSet();

    for (final activity in allActivities) {
      final isWithinReminderWindow =
          activity.dateTime.isAfter(now) && activity.dateTime.isBefore(reminderWindowEnd);
      if (!isWithinReminderWindow) {
        continue;
      }
      if (reminderKeys.contains(activity.id)) {
        continue;
      }

      await _notificationService.createNotification(
        userId: userId,
        title: 'Event Reminder',
        message: '${activity.title} starts within 24 hours.',
        activityId: activity.id,
        createdByName: 'FitConnect',
        notificationType: 'event_reminder_24h',
      );
      reminderKeys.add(activity.id);
    }
  }

  Future<String?> _resolveImageUrl({
    required String userId,
    String? existingImageUrl,
    String? imageFilePath,
  }) async {
    if (imageFilePath == null || imageFilePath.isEmpty) {
      return existingImageUrl;
    }

    if (!FirestoreService.isAvailable) {
      return imageFilePath;
    }

    return _uploadImageToCloudinary(
      imageFilePath: imageFilePath,
      userId: userId,
    );
  }

  Future<String> _uploadImageToCloudinary({
    required String imageFilePath,
    required String userId,
  }) async {
    if (AppConstants.cloudinaryCloudName == 'YOUR_CLOUD_NAME' ||
        AppConstants.cloudinaryUploadPreset == 'YOUR_UNSIGNED_UPLOAD_PRESET') {
      throw Exception(
        'Cloudinary is not configured. Set cloud name and unsigned upload preset in AppConstants.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
      ),
    );

    request.fields['upload_preset'] = AppConstants.cloudinaryUploadPreset;
    request.fields['folder'] = AppConstants.cloudinaryUploadFolder;
    request.fields['public_id'] = 'activity_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFilePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cloudinary upload failed: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = decoded['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary upload did not return an image URL');
    }

    return secureUrl;
  }
}
