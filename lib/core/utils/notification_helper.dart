import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationHelper {
  static final NotificationHelper instance = NotificationHelper._init();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  NotificationHelper._init();

  // Notification channel IDs
  static const String channelTimerEnd = 'timer_end';
  static const String channelScheduled = 'scheduled_reminder';
  static const String channelReview = 'review_reminder';

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize timezone database for zonedSchedule
    tz_data.initializeTimeZones();

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    await _createChannels();

    // Initialize alarm manager
    await AndroidAlarmManager.initialize();
  }

  Future<void> _createChannels() async {
    final androidPlugin = AndroidFlutterLocalNotificationsPlugin();

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        channelTimerEnd,
        '计时结束',
        description: '番茄钟计时完成时发出提醒',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        channelScheduled,
        '定时提醒',
        description: '到设定时间提醒你开始学习',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        channelReview,
        '复习提醒',
        description: '每天晚上提醒你回顾今天的学习',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  /// Show timer end notification
  Future<void> showTimerEnd({String? message}) async {
    await _plugin.show(
      0,
      '计时完成！',
      message ?? '本次专注已结束，休息一下吧~',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelTimerEnd,
          '计时结束',
          channelDescription: '番茄钟计时完成时发出提醒',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Schedule a daily reminder
  Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String message,
  }) async {
    // Cancel previous if exists
    await _plugin.cancel(id);

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      '学习提醒',
      message,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelScheduled,
          '定时提醒',
          channelDescription: '到设定时间提醒你开始学习',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to timer page
    // Handled via navigation callback registered with the app
  }
}
