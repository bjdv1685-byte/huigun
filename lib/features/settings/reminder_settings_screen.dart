import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/notification_config.dart';
import 'providers/settings_provider.dart';
import 'widgets/reminder_tile.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends ConsumerState<ReminderSettingsScreen> {
  List<NotificationConfig> _configs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    final repo = ref.read(settingsRepoProvider);
    final configs = await repo.getAllNotificationConfigs();
    if (!mounted) return;
    setState(() {
      _configs = configs;
      _loading = false;
    });
  }

  Future<void> _onToggle(NotificationConfig config, bool enabled) async {
    final repo = ref.read(settingsRepoProvider);
    final updated = config.copyWith(isEnabled: enabled);
    await repo.updateNotificationConfig(updated);
    await _loadConfigs();
  }

  Future<void> _onTimeChanged(NotificationConfig config, String time) async {
    final repo = ref.read(settingsRepoProvider);
    final updated = config.copyWith(timeOfDay: time);
    await repo.updateNotificationConfig(updated);
    await _loadConfigs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.reminderSettings),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _configs.map((config) {
                return ReminderTile(
                  config: config,
                  onToggle: (enabled) => _onToggle(config, enabled),
                  onTimeChanged: (time) => _onTimeChanged(config, time),
                );
              }).toList(),
            ),
    );
  }
}
