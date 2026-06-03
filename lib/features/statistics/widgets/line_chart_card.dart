import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/statistics_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/extensions/duration_extensions.dart';

/// A card that renders a line chart of daily focus time over the selected
/// dimension, with a category selector dropdown.
class LineChartCard extends StatelessWidget {
  final List<LinePoint> linePoints;
  final List<PieSection> categories; // for dropdown options
  final String? selectedCategoryId;
  final ValueChanged<String> onCategoryChanged;
  final String dimension;

  const LineChartCard({
    super.key,
    required this.linePoints,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.dimension,
  });

  String get _title {
    switch (dimension) {
      case 'day':
        return '今日趋势';
      case 'week':
        return '一周趋势';
      case 'month':
        return '本月趋势';
      case 'quarter':
        return '本季趋势';
      default:
        return '趋势';
    }
  }

  /// The categoryId that the dropdown should display as selected.
  String? get _effectiveCategoryId =>
      selectedCategoryId ?? (categories.isNotEmpty ? categories.first.categoryId : null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with optional dropdown
              Row(
                children: [
                  Text(_title, style: AppTextStyles.cardTitle),
                  const Spacer(),
                  if (categories.isNotEmpty)
                    _buildCategoryDropdown(),
                ],
              ),
              const SizedBox(height: 16),
              if (linePoints.isEmpty)
                _buildEmpty()
              else
                SizedBox(
                  height: 220,
                  child: _buildChart(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _effectiveCategoryId,
          isDense: true,
          style: AppTextStyles.caption,
          items: categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat.categoryId,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(cat.categoryName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onCategoryChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text(AppStrings.noData, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final maxY = _maxMinutes();
    // Round maxY up to a nice number for the y-axis
    final yMax = maxY <= 0 ? 10.0 : ((maxY / 10).ceil() * 10).toDouble();

    final spots = linePoints
        .map((p) => FlSpot(p.x, p.seconds.toMinutes))
        .toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: yMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yMax > 40 ? yMax / 4 : 10,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            left: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= linePoints.length) {
                  return const SizedBox.shrink();
                }
                final label = linePoints[idx].label;
                // Only show non-empty labels
                if (label.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: yMax > 40 ? yMax / 4 : 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final minutes = spot.y;
                return LineTooltipItem(
                  '${minutes.toInt()}分钟',
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.accentPrimary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: linePoints.length <= 31,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.accentPrimary,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accentPrimary.withValues(alpha: 0.25),
                  AppColors.accentPrimary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Maximum y-value (in minutes) across all line points, floored at 0.
  double _maxMinutes() {
    if (linePoints.isEmpty) return 0;
    return linePoints
        .map((p) => p.seconds.toMinutes)
        .reduce((a, b) => a > b ? a : b);
  }
}
