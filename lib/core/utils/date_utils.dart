import '../extensions/date_extensions.dart';

class DateUtils {
  DateUtils._();

  /// 获取某天的日期范围（毫秒时间戳）
  static ({int start, int end}) dayRange(DateTime date) {
    return (
      start: date.startOfDay.toTimestampMs,
      end: date.endOfDay.toTimestampMs,
    );
  }

  /// 获取本周的日期范围
  static ({int start, int end}) weekRange(DateTime date) {
    return (
      start: date.startOfWeek.toTimestampMs,
      end: date.endOfWeek.toTimestampMs,
    );
  }

  /// 获取本月的日期范围
  static ({int start, int end}) monthRange(DateTime date) {
    return (
      start: date.startOfMonth.toTimestampMs,
      end: date.endOfMonth.toTimestampMs,
    );
  }

  /// 获取本季度的日期范围
  static ({int start, int end}) quarterRange(DateTime date) {
    return (
      start: date.startOfQuarter.toTimestampMs,
      end: date.endOfQuarter.toTimestampMs,
    );
  }

  /// 根据维度获取日期范围
  static ({int start, int end}) getRange(
    DateTime date,
    String dimension, // 'day' | 'week' | 'month' | 'quarter'
  ) {
    switch (dimension) {
      case 'week':
        return weekRange(date);
      case 'month':
        return monthRange(date);
      case 'quarter':
        return quarterRange(date);
      case 'day':
      default:
        return dayRange(date);
    }
  }

  /// 生成一周内每天的日期标签列表
  static List<String> weekDayLabels(DateTime date) {
    final monday = date.startOfWeek;
    const weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return '${weekDays[i]}\n${d.month}/${d.day}';
    });
  }

  /// 格式毫秒时间戳为日期字符串 "MM/dd"
  static String formatMsToDate(int timestampMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  /// 格式秒数为"X时Y分"
  static String formatSeconds(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}时${minutes}分';
    }
    return '${minutes}分';
  }
}
