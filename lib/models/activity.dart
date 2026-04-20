import 'package:uuid/uuid.dart';
import 'activity_type.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final ActivityType type;
  final String location;
  final DateTime dateTime;
  final int maxParticipants;
  final List<String> participantIds; // User IDs of participants
  final String createdBy; // User ID of creator
  final String? creatorPhone;
  final DateTime createdAt;
  final bool isJoined;

  Activity({
    String? id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.location,
    required this.dateTime,
    required this.maxParticipants,
    List<String>? participantIds,
    required this.createdBy,
    this.creatorPhone,
    DateTime? createdAt,
    this.isJoined = false,
  }) : id = id ?? const Uuid().v4(),
       participantIds = participantIds ?? [],
       createdAt = createdAt ?? DateTime.now();

  // Get number of joined participants
  int get participantCount => participantIds.length;

  // Get available spots
  int get availableSpots => maxParticipants - participantCount;

  // Check if activity is full
  bool get isFull => availableSpots <= 0;

  // Check if activity is happening soon (within 7 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    return difference >= 0 && difference <= 7;
  }

  // Convert Activity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'createdBy': createdBy,
      'creatorPhone': creatorPhone,
      'createdAt': createdAt.toIso8601String(),
      'isJoined': isJoined,
    };
  }

  // Create Activity from JSON
  factory Activity.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return Activity(
      id: (json['id'] as String?) ?? documentId,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ActivityType.gym,
      ),
      location: json['location'] as String,
      dateTime: _parseDateTime(json['dateTime']) ?? DateTime.now(),
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
      participantIds: List<String>.from(json['participantIds'] as List? ?? []),
      createdBy: json['createdBy'] as String,
      creatorPhone: json['creatorPhone'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      isJoined: json['isJoined'] as bool? ?? false,
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

  // Copy with method for immutability
  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    ActivityType? type,
    String? location,
    DateTime? dateTime,
    int? maxParticipants,
    List<String>? participantIds,
    String? createdBy,
    String? creatorPhone,
    DateTime? createdAt,
    bool? isJoined,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      createdBy: createdBy ?? this.createdBy,
      creatorPhone: creatorPhone ?? this.creatorPhone,
      createdAt: createdAt ?? this.createdAt,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}
