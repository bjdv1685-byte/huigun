import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../models/timer_session.dart';

class SessionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<TimerSession> insert({
    required String categoryId,
    required int startTime,
    int endTime = 0,
    int durationSeconds = 0,
    SessionType sessionType = SessionType.focus,
    SessionStatus status = SessionStatus.running,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final session = TimerSession(
      id: _uuid.v4(),
      categoryId: categoryId,
      startTime: startTime,
      endTime: endTime > 0 ? endTime : null,
      durationSeconds: durationSeconds,
      sessionType: sessionType,
      status: status,
      createdAt: now,
    );
    await db.insert(DB.timerSessions, session.toMap());
    return session;
  }

  Future<void> updateEndStatus({
    required String id,
    required int endTime,
    required int durationSeconds,
    required SessionStatus status,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      DB.timerSessions,
      {
        DB.tsEndTime: endTime,
        DB.tsDurationSeconds: durationSeconds,
        DB.tsStatus: status.index,
      },
      where: '${DB.id} = ?',
      whereArgs: [id],
    );
  }

  /// Get total duration per category within a date range
  Future<Map<String, int>> getCategoryDistribution(
    int startTime,
    int endTime,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT ${DB.tsCategoryId}, SUM(${DB.tsDurationSeconds}) as total_seconds
      FROM ${DB.timerSessions}
      WHERE ${DB.tsStartTime} >= ? AND ${DB.tsStartTime} <= ?
        AND ${DB.tsStatus} = ? AND ${DB.tsSessionType} = ?
      GROUP BY ${DB.tsCategoryId}
    ''', [startTime, endTime, SessionStatus.completed.index, SessionType.focus.index]);

    final map = <String, int>{};
    for (final row in result) {
      map[row[DB.tsCategoryId] as String] = (row['total_seconds'] as int?) ?? 0;
    }
    return map;
  }

  /// Get daily duration for a specific category within a date range
  Future<Map<String, int>> getDailyByCategory(
    String categoryId,
    int startTime,
    int endTime,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT date(${DB.tsStartTime} / 1000, 'unixepoch', 'localtime') as day,
             SUM(${DB.tsDurationSeconds}) as total_seconds
      FROM ${DB.timerSessions}
      WHERE ${DB.tsCategoryId} = ?
        AND ${DB.tsStartTime} >= ? AND ${DB.tsStartTime} <= ?
        AND ${DB.tsStatus} = ? AND ${DB.tsSessionType} = ?
      GROUP BY day
      ORDER BY day ASC
    ''', [categoryId, startTime, endTime, SessionStatus.completed.index, SessionType.focus.index]);

    final map = <String, int>{};
    for (final row in result) {
      map[row['day'] as String] = (row['total_seconds'] as int?) ?? 0;
    }
    return map;
  }

  /// Get total completed focus seconds within date range
  Future<int> getTotalFocusSeconds(int startTime, int endTime) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(${DB.tsDurationSeconds}), 0) as total
      FROM ${DB.timerSessions}
      WHERE ${DB.tsStartTime} >= ? AND ${DB.tsStartTime} <= ?
        AND ${DB.tsStatus} = ? AND ${DB.tsSessionType} = ?
    ''', [startTime, endTime, SessionStatus.completed.index, SessionType.focus.index]);
    return (result.first['total'] as int?) ?? 0;
  }

  /// Get total completed session count within date range
  Future<int> getSessionCount(int startTime, int endTime) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as cnt
      FROM ${DB.timerSessions}
      WHERE ${DB.tsStartTime} >= ? AND ${DB.tsStartTime} <= ?
        AND ${DB.tsStatus} = ? AND ${DB.tsSessionType} = ?
    ''', [startTime, endTime, SessionStatus.completed.index, SessionType.focus.index]);
    return (result.first['cnt'] as int?) ?? 0;
  }
}
