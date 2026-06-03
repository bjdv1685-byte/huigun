enum SessionType { focus, break_ }

enum SessionStatus { running, completed, cancelled }

class TimerSession {
  final String id;
  final String categoryId;
  final int startTime;
  final int? endTime;
  final int durationSeconds;
  final SessionType sessionType;
  final SessionStatus status;
  final int createdAt;

  const TimerSession({
    required this.id,
    required this.categoryId,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    this.sessionType = SessionType.focus,
    this.status = SessionStatus.running,
    required this.createdAt,
  });

  TimerSession copyWith({
    String? id,
    String? categoryId,
    int? startTime,
    int? endTime,
    int? durationSeconds,
    SessionType? sessionType,
    SessionStatus? status,
    int? createdAt,
  }) {
    return TimerSession(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'start_time': startTime,
      'end_time': endTime,
      'duration_seconds': durationSeconds,
      'session_type': sessionType.index,
      'status': status.index,
      'created_at': createdAt,
    };
  }

  factory TimerSession.fromMap(Map<String, dynamic> map) {
    return TimerSession(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      startTime: map['start_time'] as int,
      endTime: map['end_time'] as int?,
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      sessionType: SessionType.values[map['session_type'] as int? ?? 0],
      status: SessionStatus.values[map['status'] as int? ?? 0],
      createdAt: map['created_at'] as int,
    );
  }
}
