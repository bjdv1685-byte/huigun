import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/database/database_constants.dart';

/// Repository provider for SettingsRepository.
final settingsRepoProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Immutable state for app settings.
class SettingsState {
  final int focusDurationMinutes;
  final int breakDurationMinutes;

  const SettingsState({
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
  });
}

/// AsyncNotifier for managing app settings (focus/break durations).
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final repo = ref.read(settingsRepoProvider);
    final focus =
        await repo.getInt(DB.settingFocusDuration, defaultValue: 25);
    final break_ =
        await repo.getInt(DB.settingBreakDuration, defaultValue: 5);
    return SettingsState(
      focusDurationMinutes: focus,
      breakDurationMinutes: break_,
    );
  }

  Future<void> setFocusDuration(int minutes) async {
    final repo = ref.read(settingsRepoProvider);
    await repo.setInt(DB.settingFocusDuration, minutes);
    state = AsyncData(SettingsState(
      focusDurationMinutes: minutes,
      breakDurationMinutes: state.value?.breakDurationMinutes ?? 5,
    ));
  }

  Future<void> setBreakDuration(int minutes) async {
    final repo = ref.read(settingsRepoProvider);
    await repo.setInt(DB.settingBreakDuration, minutes);
    state = AsyncData(SettingsState(
      focusDurationMinutes: state.value?.focusDurationMinutes ?? 25,
      breakDurationMinutes: minutes,
    ));
  }
}
