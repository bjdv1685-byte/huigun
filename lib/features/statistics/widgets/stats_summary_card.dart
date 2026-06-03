import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_utils.dart' as app_date;

/// A card that displays three summary statistics in a row:
/// total focus time, session count, and daily average.
class StatsSummaryCard extends StatelessWidget {
  final int totalSeconds;
  final int sessionCount;
  final double dailyAverageMinutes;

  const StatsSummaryCard({
    super.key,
    required this.totalSeconds,
    required this.sessionCount,
    required this.dailyAverageMinutes,
  });

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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              _StatItem(
                label: AppStrings.totalFocus,
                value: app_date.DateUtils.formatSeconds(totalSeconds),
              ),
              _buildDivider(),
              _StatItem(
                label: AppStrings.totalSessions,
                value: '$sessionCount次',
              ),
              _buildDivider(),
              _StatItem(
                label: AppStrings.dailyAverage,
                value: '${dailyAverageMinutes.round()}${AppStrings.minutes}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: AppColors.border.withValues(alpha: 0.6),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTextStyles.statNumber),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}
