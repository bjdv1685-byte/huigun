import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/statistics_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';

/// A card that renders a pie chart of category time distribution.
class PieChartCard extends StatelessWidget {
  final List<PieSection> sections;
  final String dimension;

  const PieChartCard({
    super.key,
    required this.sections,
    required this.dimension,
  });

  String get _title {
    switch (dimension) {
      case 'day':
        return '今日时间分布';
      case 'week':
        return '本周时间分布';
      case 'month':
        return '本月时间分布';
      case 'quarter':
        return '本季时间分布';
      default:
        return '时间分布';
    }
  }

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
              Text(_title, style: AppTextStyles.cardTitle),
              const SizedBox(height: 16),
              if (sections.isEmpty)
                _buildEmpty()
              else ...[
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections: _buildSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildLegend(),
              ],
            ],
          ),
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
            Icon(Icons.pie_chart_outline_rounded, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text(AppStrings.noData, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return sections.map((section) {
      final showTitle = section.percentage > 10;
      return PieChartSectionData(
        value: section.seconds.toDouble(),
        color: section.color,
        title: showTitle ? '${section.percentage.toStringAsFixed(0)}%' : '',
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: sections.map((section) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: section.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${section.categoryName} ${section.percentage.toStringAsFixed(0)}%',
              style: AppTextStyles.caption,
            ),
          ],
        );
      }).toList(),
    );
  }
}
