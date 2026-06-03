class AppDurations {
  AppDurations._();

  /// 默认专注时长（秒）
  static const int defaultFocusSeconds = 25 * 60;

  /// 默认休息时长（秒）
  static const int defaultBreakSeconds = 5 * 60;

  /// 闪屏缓冲时长
  static const int splashDelaySeconds = 2;

  /// 最短专注时长（分钟）
  static const int minFocusMinutes = 5;

  /// 最长专注时长（分钟）
  static const int maxFocusMinutes = 120;

  /// 最短休息时长（分钟）
  static const int minBreakMinutes = 1;

  /// 最长休息时长（分钟）
  static const int maxBreakMinutes = 30;
}
