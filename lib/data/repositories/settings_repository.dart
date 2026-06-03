import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../models/notification_config.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- App Settings (key-value) ---

  Future<String?> getString(String key) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DB.appSettings,
      where: '${DB.asKey} = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first[DB.asValue] as String;
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final val = await getString(key);
    if (val == null) return defaultValue;
    return int.tryParse(val) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      DB.appSettings,
      {DB.asKey: key, DB.asValue: value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  // --- Notification Configs ---

  Future<List<NotificationConfig>> getAllNotificationConfigs() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DB.notificationConfigs);
    return maps.map((m) => NotificationConfig.fromMap(m)).toList();
  }

  Future<NotificationConfig?> getNotificationConfig(NotificationType type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DB.notificationConfigs,
      where: '${DB.ncNotifType} = ?',
      whereArgs: [type.index],
    );
    if (maps.isEmpty) return null;
    return NotificationConfig.fromMap(maps.first);
  }

  Future<void> updateNotificationConfig(NotificationConfig config) async {
    final db = await _dbHelper.database;
    await db.update(
      DB.notificationConfigs,
      config.toMap(),
      where: '${DB.id} = ?',
      whereArgs: [config.id],
    );
  }
}
