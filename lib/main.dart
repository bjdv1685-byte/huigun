import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database/database_helper.dart';
import 'core/utils/notification_helper.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize notifications
  await NotificationHelper.instance.init();

  runApp(
    const ProviderScope(
      child: PomodoroApp(),
    ),
  );
}
