import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/data/models/timer_session.dart';
import 'package:pomodoro_app/core/constants/app_colors.dart';
import 'package:pomodoro_app/core/theme/text_styles.dart';
import 'package:pomodoro_app/core/extensions/duration_extensions.dart';
import 'package:pomodoro_app/features/timer/providers/timer_provider.dart';
import 'package:pomodoro_app/features/timer/providers/category_provider.dart';
import 'progress_ring.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final isBreak = timerState.sessionType == SessionType.break_;
    final foregroundColor =
        isBreak ? AppColors.timerRingBreak : AppColors.timerRingFocus;
    final digitColor =
        isBreak ? AppColors.timerDigitBreak : AppColors.timerDigitFocus;

    // Resolve category name from the async list
    final categoryName = categoriesAsync.whenOrNull(
          data: (categories) {
            if (timerState.categoryId == null) return '';
            final match = categories.where(
              (c) => c.id == timerState.categoryId,
            );
            return match.isNotEmpty ? match.first.name : '';
          },
        ) ??
        '';

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ProgressRing(
            progress: timerState.progress,
            backgroundColor: AppColors.timerRingBg,
            foregroundColor: foregroundColor,
            strokeWidth: 12,
            size: 260,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timerState.remainingSeconds.toDisplayMMSS,
                style: AppTextStyles.timerDigit.copyWith(color: digitColor),
              ),
              if (categoryName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  categoryName,
                  style: AppTextStyles.timerCategory,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
