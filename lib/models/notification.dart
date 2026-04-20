import 'package:uuid/uuid.dart';

class AppNotification {
  final String id;
  final String userId; // User who received the notification
  final String title;
  final String message;
  final String activityId;
  final String createdByName; // Name of the user who created/triggered the notification
  final String notificationType; // 'activity_created', 'activity_joined', etc.
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    String? id,
    required this.userId,
    required this.title,
    required this.message,
    required this.activityId,
    required this.createdByName,
    required this.notificationType,
    DateTime? createdAt,
    this.isRead = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'activityId': activityId,
      'createdByName': createdByName,
      'notificationType': notificationType,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return AppNotification(
      id: (json['id'] as String?) ?? documentId,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      activityId: json['activityId'] as String,
      createdByName: json['createdByName'] as String,
      notificationType: json['notificationType'] as String,
      createdAt: _parseDateTime(json['createdAt']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    final dynamic seconds = value.seconds;
    final dynamic nanoseconds = value.nanoseconds;
    if (seconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (seconds as int) * 1000 + ((nanoseconds as int?) ?? 0) ~/ 1000000,
      );
    }
    return null;
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? activityId,
    String? createdByName,
    String? notificationType,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      activityId: activityId ?? this.activityId,
      createdByName: createdByName ?? this.createdByName,
      notificationType: notificationType ?? this.notificationType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
