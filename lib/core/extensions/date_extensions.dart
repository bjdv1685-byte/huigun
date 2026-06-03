extension DateExtensions on DateTime {
  /// 获取当天开始时间 (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// 获取当天结束时间 (23:59:59.999)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// 获取本周一
  DateTime get startOfWeek {
    final weekday = this.weekday;
    return DateTime(year, month, day - weekday + 1).startOfDay;
  }

  /// 获取本周日结束
  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 7)).startOfDay.subtract(const Duration(milliseconds: 1));

  /// 获取本月第一天
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// 获取本月最后一天
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// 获取本季度第一天
  DateTime get startOfQuarter {
    final quarterMonth = ((month - 1) ~/ 3) * 3 + 1;
    return DateTime(year, quarterMonth, 1);
  }

  /// 获取本季度最后一天
  DateTime get endOfQuarter {
    final quarterEndMonth = ((month - 1) ~/ 3 + 1) * 3;
    return DateTime(year, quarterEndMonth + 1, 0, 23, 59, 59, 999);
  }

  /// 季度标签
  String get quarterLabel {
    final q = ((month - 1) ~/ 3) + 1;
    return '${year}Q$q';
  }

  /// 转换为毫秒时间戳
  int get toTimestampMs => millisecondsSinceEpoch;
}

extension TimestampMs on int {
  /// 从毫秒时间戳转为 DateTime
  DateTime get toDateTime => DateTime.fromMillisecondsSinceEpoch(this);
}
