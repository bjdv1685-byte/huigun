import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// A horizontal row of [ChoiceChip] widgets for selecting the statistics
/// time dimension: 日 / 周 / 月 / 季.
class DimensionSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const DimensionSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _dimensions = ['day', 'week', 'month', 'quarter'];
  static const _labels = ['日', '周', '月', '季'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_dimensions.length, (index) {
          final dim = _dimensions[index];
          final label = _labels[index];
          final isSelected = dim == selected;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
            ),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(dim),
              selectedColor: AppColors.accentPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.accentPrimary : AppColors.border,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
          );
        }),
      ),
    );
  }
}
