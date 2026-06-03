/// Database table and column name constants.
class DB {
  DB._();

  // Tables
  static const String categories = 'categories';
  static const String timerSessions = 'timer_sessions';
  static const String quotes = 'quotes';
  static const String quoteShownHistory = 'quote_shown_history';
  static const String plans = 'plans';
  static const String notificationConfigs = 'notification_configs';
  static const String appSettings = 'app_settings';

  // Common columns
  static const String id = 'id';
  static const String createdAt = 'created_at';

  // categories columns
  static const String catName = 'name';
  static const String catColorValue = 'color_value';
  static const String catSortOrder = 'sort_order';
  static const String catIsDefault = 'is_default';
  static const String catIsDeleted = 'is_deleted';

  // timer_sessions columns
  static const String tsCategoryId = 'category_id';
  static const String tsStartTime = 'start_time';
  static const String tsEndTime = 'end_time';
  static const String tsDurationSeconds = 'duration_seconds';
  static const String tsSessionType = 'session_type';
  static const String tsStatus = 'status';

  // quotes columns
  static const String qText = 'text';
  static const String qQuarterLabel = 'quarter_label';

  // quote_shown_history columns
  static const String qshQuoteId = 'quote_id';
  static const String qshShownAt = 'shown_at';

  // plans columns
  static const String pContent = 'content';
  static const String pItemType = 'item_type';
  static const String pIsCompleted = 'is_completed';
  static const String pCompletedAt = 'completed_at';
  static const String pIsDeleted = 'is_deleted';

  // notification_configs columns
  static const String ncNotifType = 'notif_type';
  static const String ncIsEnabled = 'is_enabled';
  static const String ncTimeOfDay = 'time_of_day';
  static const String ncMessage = 'message';

  // app_settings columns
  static const String asKey = 'key';
  static const String asValue = 'value';

  // Settings keys
  static const String settingFocusDuration = 'focus_duration_minutes';
  static const String settingBreakDuration = 'break_duration_minutes';
  static const String settingLongBreakDuration = 'long_break_duration_minutes';
  static const String settingSessionsBeforeLongBreak = 'sessions_before_long_break';
}
