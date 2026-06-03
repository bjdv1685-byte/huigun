import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/models/timer_session.dart';
import 'package:pomodoro_app/core/utils/notification_helper.dart';
import 'package:pomodoro_app/features/timer/services/timer_service.dart';

/// Providers for injected dependencies.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final notificationHelperProvider = Provider<NotificationHelper>((ref) {
  return NotificationHelper.instance;
});

final timerServiceProvider = Provider<TimerService>((ref) {
  final service = TimerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// ── Timer State ──

enum TimerStatus { idle, running, paused, finished }

class TimerState {
  final TimerStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final String? categoryId;
  final SessionType sessionType;
  final String? sessionId;
  final int startTime;

  const TimerState({
    this.status = TimerStatus.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.categoryId,
    this.sessionType = SessionType.focus,
    this.sessionId,
    this.startTime = 0,
  });

  TimerState copyWith({
    TimerStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    String? categoryId,
    SessionType? sessionType,
    String? sessionId,
    int? startTime,
    bool clearCategoryId = false,
    bool clearSessionId = false,
  }) {
    return TimerState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      categoryId:
          clearCategoryId ? null : (categoryId ?? this.categoryId),
      sessionType: sessionType ?? this.sessionType,
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      startTime: startTime ?? this.startTime,
    );
  }

  double get progress =>
      totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0;
}

/// ── Timer Notifier ──

class TimerNotifier extends Notifier<TimerState> {
  StreamSubscription<int>? _tickSubscription;

  @override
  TimerState build() {
    ref.onDispose(() {
      _tickSubscription?.cancel();
    });
    return const TimerState();
  }

  /// Select a category for the next session (only when idle or finished).
  void selectCategory(String categoryId) {
    if (state.status == TimerStatus.idle ||
        state.status == TimerStatus.finished) {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  /// Start a new timer session.
  Future<void> start(
    String categoryId,
    int durationSeconds,
    SessionType sessionType,
  ) async {
    // Guard: don't start if already running
    if (state.status == TimerStatus.running ||
        state.status == TimerStatus.paused) {
      return;
    }

    final sessionRepo = ref.read(sessionRepositoryProvider);
    final timerService = ref.read(timerServiceProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Create session record in DB
    final session = await sessionRepo.insert(
      categoryId: categoryId,
      startTime: now,
      durationSeconds: durationSeconds,
      sessionType: sessionType,
    );

    // Cancel any previous tick subscription
    _tickSubscription?.cancel();

    // Listen to timer ticks
    _tickSubscription = timerService.onTick.listen((remaining) {
      if (remaining >= 0) {
        state = state.copyWith(remainingSeconds: remaining);
      }
    });

    // Set initial running state
    state = TimerState(
      status: TimerStatus.running,
      remainingSeconds: durationSeconds,
      totalSeconds: durationSeconds,
      categoryId: categoryId,
      sessionType: sessionType,
      sessionId: session.id,
      startTime: now,
    );

    // Kick off the timer service
    timerService.start(durationSeconds, onComplete: _onComplete);
  }

  /// Pause the running timer.
  void pause() {
    if (state.status != TimerStatus.running) return;
    ref.read(timerServiceProvider).pause();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// Resume a paused timer.
  void resume() {
    if (state.status != TimerStatus.paused) return;
    ref.read(timerServiceProvider).resume(onComplete: _onComplete);
    state = state.copyWith(status: TimerStatus.running);
  }

  /// Stop the timer and mark the session as cancelled.
  Future<void> stop() async {
    if (state.status == TimerStatus.idle) return;

    ref.read(timerServiceProvider).stop();
    _tickSubscription?.cancel();
    _tickSubscription = null;

    // Update session in DB as cancelled
    if (state.sessionId != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = state.totalSeconds - state.remainingSeconds;
      await ref.read(sessionRepositoryProvider).updateEndStatus(
            id: state.sessionId!,
            endTime: now,
            durationSeconds: elapsed.clamp(0, state.totalSeconds),
            status: SessionStatus.cancelled,
          );
    }

    state = const TimerState();
  }

  /// Called when the timer service reaches zero.
  Future<void> _onComplete() async {
    _tickSubscription?.cancel();
    _tickSubscription = null;

    // Update session in DB as completed
    if (state.sessionId != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await ref.read(sessionRepositoryProvider).updateEndStatus(
            id: state.sessionId!,
            endTime: now,
            durationSeconds: state.totalSeconds,
            status: SessionStatus.completed,
          );
    }

    state = state.copyWith(
      status: TimerStatus.finished,
      remainingSeconds: 0,
    );

    // Show completion notification
    await ref.read(notificationHelperProvider).showTimerEnd();
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
  TimerNotifier.new,
);
