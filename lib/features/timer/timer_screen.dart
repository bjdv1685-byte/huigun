import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/core/constants/app_strings.dart';
import 'package:pomodoro_app/core/constants/app_durations.dart';
import 'package:pomodoro_app/data/models/timer_session.dart';
import 'providers/timer_provider.dart';
import 'providers/category_provider.dart';
import 'widgets/category_selector.dart';
import 'widgets/timer_display.dart';
import 'widgets/timer_controls.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final isIdle = timerState.status == TimerStatus.idle ||
        timerState.status == TimerStatus.finished;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Category selector ──
            CategorySelector(
              selectedId: timerState.categoryId,
              onSelected: (category) {
                if (isIdle) {
                  ref.read(timerProvider.notifier).selectCategory(category.id);
                }
              },
            ),

            const Spacer(),

            // ── Central timer display ──
            const TimerDisplay(),

            const Spacer(),

            // ── Bottom controls ──
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: TimerControls(
                status: timerState.status,
                onStart: () => _handleStart(context, ref),
                onPause: () => ref.read(timerProvider.notifier).pause(),
                onResume: () => ref.read(timerProvider.notifier).resume(),
                onStop: () => ref.read(timerProvider.notifier).stop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resolve a valid category id before starting the timer.
  /// If no category is selected, auto-pick the first available category.
  void _handleStart(BuildContext context, WidgetRef ref) {
    final timerNotifier = ref.read(timerProvider.notifier);
    final timerState = ref.read(timerProvider);
    String? categoryId = timerState.categoryId;

    // If no category selected, try to grab the first one from the list
    if (categoryId == null) {
      final categories = ref.read(categoryListProvider).valueOrNull;
      if (categories != null && categories.isNotEmpty) {
        categoryId = categories.first.id;
        timerNotifier.selectCategory(categoryId);
      }
    }

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.selectCategory),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    timerNotifier.start(
      categoryId,
      AppDurations.defaultFocusSeconds,
      SessionType.focus,
    );
  }
}
