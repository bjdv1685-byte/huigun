import 'package:flutter/material.dart';
import 'package:pomodoro_app/core/constants/app_colors.dart';
import 'package:pomodoro_app/features/timer/providers/timer_provider.dart';

class TimerControls extends StatelessWidget {
  final TimerStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const TimerControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final showStop =
        status == TimerStatus.running || status == TimerStatus.paused;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStop) ...[
          _SmallIconButton(
            icon: Icons.stop,
            tooltip: '停止',
            onTap: onStop,
          ),
          const SizedBox(width: 24),
        ],
        _MainButton(
          status: status,
          onStart: onStart,
          onPause: onPause,
          onResume: onResume,
        ),
      ],
    );
  }
}

class _MainButton extends StatelessWidget {
  final TimerStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const _MainButton({
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    VoidCallback? onTap;

    switch (status) {
      case TimerStatus.running:
        icon = Icons.pause;
        onTap = onPause;
      case TimerStatus.paused:
        icon = Icons.play_arrow;
        onTap = onResume;
      case TimerStatus.idle:
      case TimerStatus.finished:
        icon = Icons.play_arrow;
        onTap = onStart;
    }

    return SizedBox(
      width: 72,
      height: 72,
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: AppColors.accentPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(icon, size: 36, color: Colors.white),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SmallIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        tooltip: tooltip,
        color: AppColors.textSecondary,
        iconSize: 28,
      ),
    );
  }
}
