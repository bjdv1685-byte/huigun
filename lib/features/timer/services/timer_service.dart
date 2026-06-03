import 'dart:async';
import 'dart:ui';

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  final StreamController<int> _controller = StreamController<int>.broadcast();

  Stream<int> get onTick => _controller.stream;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  double get progress =>
      _totalSeconds > 0
          ? (_totalSeconds - _remainingSeconds) / _totalSeconds
          : 0;
  bool get isRunning => _timer != null;

  void start(int seconds, {required VoidCallback onComplete}) {
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

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void resume({required VoidCallback onComplete}) {
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
    _controller.add(0);
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
