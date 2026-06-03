import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/models/category.dart';
import '../../../core/utils/date_utils.dart' as app_date;

// ── Repository providers ─────────────────────────────────────────────────────

final sessionRepoProvider = Provider<SessionRepository>((ref) => SessionRepository());

final categoryRepoProvider = Provider<CategoryRepository>((ref) => CategoryRepository());

// ── Params / Data classes ────────────────────────────────────────────────────

class StatisticsParams {
  final String dimension; // 'day' | 'week' | 'month' | 'quarter'
  final String? categoryId; // null means all categories
  final DateTime date;

  const StatisticsParams({
    this.dimension = 'day',
    this.categoryId,
    required this.date,
  });

  @override
  bool operator ==(Object other) =>
      other is StatisticsParams &&
      other.dimension == dimension &&
      other.categoryId == categoryId &&
      other.date == date;

  @override
  int get hashCode => Object.hash(dimension, categoryId, date);
}

class PieSection {
  final String categoryId;
  final String categoryName;
  final Color color;
  final int seconds;
  final double percentage; // 0-100

  const PieSection({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.seconds,
    required this.percentage,
  });
}

class LinePoint {
  final String label; // date label for x-axis
  final int seconds;
  final double x; // x-axis position (index)

  const LinePoint({
    required this.label,
    required this.seconds,
    required this.x,
  });
}

class StatisticsData {
  final List<PieSection> pieSections;
  final List<LinePoint> linePoints;
  final int totalSeconds;
  final int sessionCount;
  final double dailyAverageMinutes;

  const StatisticsData({
    required this.pieSections,
    required this.linePoints,
    required this.totalSeconds,
    required this.sessionCount,
    required this.dailyAverageMinutes,
  });

  bool get hasData => totalSeconds > 0 && pieSections.isNotEmpty;
}

// ── Provider ─────────────────────────────────────────────────────────────────

final statisticsProvider = AsyncNotifierProvider.family<StatisticsNotifier, StatisticsData, StatisticsParams>(
  StatisticsNotifier.new,
);

class StatisticsNotifier extends FamilyAsyncNotifier<StatisticsData, StatisticsParams> {
  @override
  Future<StatisticsData> build(StatisticsParams arg) async {
    final sessionRepo = ref.read(sessionRepoProvider);
    final categoryRepo = ref.read(categoryRepoProvider);

    // 1. Get date range
    final range = app_date.DateUtils.getRange(arg.date, arg.dimension);
    final startTime = range.start;
    final endTime = range.end;

    // 2. Get all active categories for name/color lookup
    final categories = await categoryRepo.getAllActive();
    final categoryMap = <String, Category>{};
    for (final cat in categories) {
      categoryMap[cat.id] = cat;
    }

    // 3. Get category distribution (pie data)
    final distribution = await sessionRepo.getCategoryDistribution(startTime, endTime);

    // 4. Get totals
    final totalSeconds = await sessionRepo.getTotalFocusSeconds(startTime, endTime);
    final sessionCount = await sessionRepo.getSessionCount(startTime, endTime);

    // 5. Build pie sections
    final pieSections = <PieSection>[];
    if (totalSeconds > 0) {
      for (final entry in distribution.entries) {
        final cat = categoryMap[entry.key];
        if (cat != null && entry.value > 0) {
          final percentage = (entry.value / totalSeconds) * 100.0;
          pieSections.add(PieSection(
            categoryId: cat.id,
            categoryName: cat.name,
            color: Color(cat.colorValue),
            seconds: entry.value,
            percentage: percentage,
          ));
        }
      }
      // Sort by seconds descending so largest slice appears first (consistent
      // visual order)
      pieSections.sort((a, b) => b.seconds.compareTo(a.seconds));
    }

    // 6. Build line points
    final effectiveCategoryId = arg.categoryId ?? (pieSections.isNotEmpty ? pieSections.first.categoryId : null);

    List<LinePoint> linePoints = [];
    if (effectiveCategoryId != null) {
      final dailyData = await sessionRepo.getDailyByCategory(effectiveCategoryId, startTime, endTime);
      linePoints = _buildLinePoints(dailyData, arg.date, arg.dimension);
    }

    // 7. Compute daily average
    final startDate = DateTime.fromMillisecondsSinceEpoch(startTime);
    final endDate = DateTime.fromMillisecondsSinceEpoch(endTime);
    final daysInRange = endDate.difference(startDate).inDays + 1;
    final dailyAverageMinutes = daysInRange > 0 ? (totalSeconds / daysInRange) / 60.0 : 0.0;

    return StatisticsData(
      pieSections: pieSections,
      linePoints: linePoints,
      totalSeconds: totalSeconds,
      sessionCount: sessionCount,
      dailyAverageMinutes: dailyAverageMinutes,
    );
  }

  /// Build line-chart data points from daily-duration map.
  List<LinePoint> _buildLinePoints(
    Map<String, int> dailyData,
    DateTime date,
    String dimension,
  ) {
    final entries = _expectedDateEntries(date, dimension);
    final points = <LinePoint>[];

    for (int i = 0; i < entries.length; i++) {
      points.add(LinePoint(
        label: entries[i].label,
        seconds: dailyData[entries[i].dateStr] ?? 0,
        x: i.toDouble(),
      ));
    }
    return points;
  }

  /// Produce the list of (dateStr, label) pairs that should appear on the
  /// x-axis for the given [dimension].
  List<({String dateStr, String label})> _expectedDateEntries(
    DateTime date,
    String dimension,
  ) {
    final range = app_date.DateUtils.getRange(date, dimension);
    final startDate = DateTime.fromMillisecondsSinceEpoch(range.start);
    final endDate = DateTime.fromMillisecondsSinceEpoch(range.end);

    switch (dimension) {
      case 'day':
        return [(dateStr: _fmt(startDate), label: '今日')];

      case 'week':
        final labels = app_date.DateUtils.weekDayLabels(date);
        return List.generate(7, (i) {
          final d = startDate.add(Duration(days: i));
          return (dateStr: _fmt(d), label: labels[i]);
        });

      case 'month':
        final days = endDate.day;
        return List.generate(days, (i) {
          final d = startDate.add(Duration(days: i));
          // Show label every 5 days to avoid clutter
          final showLabel = (i % 5 == 0) || i == days - 1;
          return (dateStr: _fmt(d), label: showLabel ? '${d.month}/${d.day}' : '');
        });

      case 'quarter':
        // Group by week for quarterly view
        final result = <({String dateStr, String label})>[];
        DateTime cursor = startDate;
        int weekNum = 1;
        while (cursor.isBefore(endDate) || cursor.isAtSameMomentAs(endDate)) {
          result.add((
            dateStr: _fmt(cursor),
            label: weekNum == 1 || weekNum % 3 == 0 ? 'W$weekNum' : '',
          ));
          cursor = cursor.add(const Duration(days: 7));
          weekNum++;
        }
        return result;

      default:
        return [];
    }
  }

  /// Format a [DateTime] to "YYYY-MM-DD" matching the SQLite date() output.
  String _fmt(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
