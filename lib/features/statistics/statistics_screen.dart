import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/statistics_provider.dart';
import 'widgets/dimension_selector.dart';
import 'widgets/pie_chart_card.dart';
import 'widgets/line_chart_card.dart';
import 'widgets/stats_summary_card.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedDimension = 'day';
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final params = StatisticsParams(
      dimension: _selectedDimension,
      categoryId: _selectedCategoryId,
      date: DateTime.now(),
    );

    final asyncData = ref.watch(statisticsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.tabStatistics,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: AppColors.background,
      body: asyncData.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              Text('加载失败', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                error.toString(),
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(StatisticsData data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          DimensionSelector(
            selected: _selectedDimension,
            onChanged: (dim) {
              setState(() {
                _selectedDimension = dim;
                _selectedCategoryId = null; // reset category filter on dimension change
              });
            },
          ),
          const SizedBox(height: 8),
          StatsSummaryCard(
            totalSeconds: data.totalSeconds,
            sessionCount: data.sessionCount,
            dailyAverageMinutes: data.dailyAverageMinutes,
          ),
          PieChartCard(
            sections: data.pieSections,
            dimension: _selectedDimension,
          ),
          LineChartCard(
            linePoints: data.linePoints,
            categories: data.pieSections,
            selectedCategoryId: _selectedCategoryId,
            dimension: _selectedDimension,
            onCategoryChanged: (categoryId) {
              setState(() {
                _selectedCategoryId = categoryId;
              });
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
