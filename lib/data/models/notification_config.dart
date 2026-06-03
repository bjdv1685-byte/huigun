enum NotificationType { scheduled, timerEnd, review }

class NotificationConfig {
  final String id;
  final NotificationType notifType;
  final bool isEnabled;
  final String? timeOfDay; // "HH:mm" for scheduled type
  final String? message;
  final int createdAt;

  const NotificationConfig({
    required this.id,
    required this.notifType,
    this.isEnabled = true,
    this.timeOfDay,
    this.message,
    required this.createdAt,
  });

  NotificationConfig copyWith({
    String? id,
    NotificationType? notifType,
    bool? isEnabled,
    String? timeOfDay,
    String? message,
    int? createdAt,
  }) {
    return NotificationConfig(
      id: id ?? this.id,
      notifType: notifType ?? this.notifType,
      isEnabled: isEnabled ?? this.isEnabled,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notif_type': notifType.index,
      'is_enabled': isEnabled ? 1 : 0,
      'time_of_day': timeOfDay,
      'message': message,
      'created_at': createdAt,
    };
  }

  factory NotificationConfig.fromMap(Map<String, dynamic> map) {
    return NotificationConfig(
      id: map['id'] as String,
      notifType: NotificationType.values[map['notif_type'] as int? ?? 0],
      isEnabled: (map['is_enabled'] as int?) != 0,
      timeOfDay: map['time_of_day'] as String?,
      message: map['message'] as String?,
      createdAt: map['created_at'] as int,
    );
  }
}
