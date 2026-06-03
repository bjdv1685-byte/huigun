extension DurationExtensions on Duration {
  /// 格式化为 mm:ss
  String get toDisplayMMSS {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (inHours > 0) {
      return '${inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// 格式化为"X小时Y分钟"
  String get toDisplayChinese {
    if (inHours > 0) {
      final mins = inMinutes.remainder(60);
      if (mins > 0) {
        return '$inHours小时$mins分钟';
      }
      return '$inHours小时';
    }
    final mins = inMinutes.remainder(60);
    if (mins > 0) {
      return '$mins分钟';
    }
    final secs = inSeconds.remainder(60);
    return '$secs秒';
  }

  /// 格式化为"Xh Ym"简短形式
  String get toDisplayShort {
    if (inHours > 0) {
      final mins = inMinutes.remainder(60);
      return '${inHours}h ${mins}m';
    }
    return '${inMinutes.remainder(60)}m';
  }
}

extension SecondsExtensions on int {
  /// 秒数转 Duration
  Duration get seconds => Duration(seconds: this);

  /// 秒数格式化为 mm:ss
  String get toDisplayMMSS {
    return Duration(seconds: this).toDisplayMMSS;
  }

  /// 秒数转为分钟数（浮点）
  double get toMinutes => this / 60.0;

  /// 秒数转为小时数（浮点）
  double get toHours => this / 3600.0;
}
