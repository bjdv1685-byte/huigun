import 'package:flutter/material.dart';
import '../../../data/models/notification_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';

/// A ListTile that represents a single notification / reminder config.
///
/// Displays the reminder type name, a description or current time setting,
/// a trailing [Switch] to toggle on/off, and (for scheduled & review types)
/// opens a [showTimePicker] on tap to change the time.
class ReminderTile extends StatelessWidget {
  final NotificationConfig config;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String>? onTimeChanged;

  const ReminderTile({
    super.key,
    required this.config,
    required this.onToggle,
    this.onTimeChanged,
  });

  // ── helpers ──────────────────────────────────────────────────────────

  String _title(NotificationType type) {
    switch (type) {
      case NotificationType.scheduled:
        return AppStrings.scheduledReminder;
      case NotificationType.timerEnd:
        return AppStrings.timerEndReminder;
      case NotificationType.review:
        return AppStrings.reviewReminder;
    }
  }

  String _subtitle(NotificationType type) {
    switch (type) {
      case NotificationType.scheduled:
        return config.timeOfDay != null
            ? '${AppStrings.scheduledHint} · ${config.timeOfDay}'
            : AppStrings.scheduledHint;
      case NotificationType.timerEnd:
        return AppStrings.timerEndHint;
      case NotificationType.review:
        return config.timeOfDay != null
            ? '${AppStrings.reviewHint} · ${config.timeOfDay}'
            : AppStrings.reviewHint;
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    // Parse current time-of-day or default to 09:00.
    TimeOfDay initial = const TimeOfDay(hour: 9, minute: 0);
    final current = config.timeOfDay;
    if (current != null) {
      final parts = current.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          initial = TimeOfDay(hour: h, minute: m);
        }
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.confirm,
    );

    if (picked != null && onTimeChanged != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      onTimeChanged!('$hour:$minute');
    }
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final type = config.notifType;
    final canPickTime =
        type == NotificationType.scheduled || type == NotificationType.review;

    return ListTile(
      title: Text(_title(type), style: AppTextStyles.bodyText),
      subtitle: Text(_subtitle(type), style: AppTextStyles.caption),
      trailing: Switch(
        value: config.isEnabled,
        activeThumbColor: AppColors.accentPrimary,
        onChanged: onToggle,
      ),
      onTap: canPickTime ? () => _pickTime(context) : null,
    );
  }
}
