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
    final isCountUp = timerState.isCountUp;

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
          if (!isCountUp)
            ProgressRing(
              progress: timerState.progress,
              backgroundColor: AppColors.timerRingBg,
              foregroundColor: foregroundColor,
              strokeWidth: 12,
              size: 260,
            )
          else
            // 正计时：完整圆环（静态装饰）
            CustomPaint(
              size: const Size(260, 260),
              painter: _StaticRingPainter(
                color: AppColors.timerRingFocus,
                strokeWidth: 12,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCountUp && timerState.status == TimerStatus.running)
                // 正计时运行中显示闪烁圆点
                _BlinkingDot(color: foregroundColor),
              Text(
                timerState.remainingSeconds.toDisplayMMSS,
                style: AppTextStyles.timerDigit.copyWith(color: digitColor),
              ),
              if (isCountUp && (timerState.status == TimerStatus.idle)) ...[
                const SizedBox(height: 8),
                Text(
                  '正计时',
                  style: AppTextStyles.timerCategory,
                ),
              ],
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

/// 静态圆环装饰（正计时用）
class _StaticRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _StaticRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..color = color.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _StaticRingPainter oldDelegate) => false;
}

/// 计时进行中的闪烁圆点
class _BlinkingDot extends StatefulWidget {
  final Color color;
  const _BlinkingDot({required this.color});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(
              (100 + _controller.value * 155).round(),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
