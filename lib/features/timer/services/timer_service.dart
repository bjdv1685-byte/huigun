import 'dart:async';
import 'dart:ui';

enum TimerMode { countDown, countUp }

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  TimerMode _mode = TimerMode.countDown;
  final StreamController<int> _controller = StreamController<int>.broadcast();

  Stream<int> get onTick => _controller.stream;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  TimerMode get mode => _mode;
  double get progress =>
      _totalSeconds > 0
          ? (_totalSeconds - _remainingSeconds) / _totalSeconds
          : 0;
  bool get isRunning => _timer != null;

  /// 倒计时启动
  void start(int seconds, {required VoidCallback onComplete}) {
    _mode = TimerMode.countDown;
    _totalSeconds = seconds;
    _remainingSeconds = seconds;
    _controller.add(_remainingSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      _controller.add(_remainingSeconds);
      if (_remainingSeconds <= 0) {
        stop();
        onComplete();
      }
    });
  }

  /// 正计时启动（从零开始往上计）
  void startCountUp() {
    _mode = TimerMode.countUp;
    _totalSeconds = 0; // 无上限
    _remainingSeconds = 0;
    _controller.add(_remainingSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds++;
      _controller.add(_remainingSeconds);
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void resume({required VoidCallback onComplete}) {
    if (_mode == TimerMode.countUp) {
      // 正计时恢复，继续往上计
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _remainingSeconds++;
        _controller.add(_remainingSeconds);
      });
      return;
    }
    // 倒计时恢复
    if (_remainingSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      _controller.add(_remainingSeconds);
      if (_remainingSeconds <= 0) {
        stop();
        onComplete();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = 0;
    _totalSeconds = 0;
    _mode = TimerMode.countDown;
    _controller.add(0);
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
