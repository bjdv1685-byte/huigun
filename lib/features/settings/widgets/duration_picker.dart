import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';

/// A modal bottom sheet that lets the user pick a duration in minutes
/// using a Slider. Call [DurationPicker.show] to present it.
class DurationPicker {
  /// Shows the duration picker. Returns the selected number of minutes,
  /// or `null` if the user cancels.
  static Future<int?> show({
    required BuildContext context,
    required int initialValue,
    required int min,
    required int max,
    required String title,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DurationPickerContent(
        initialValue: initialValue,
        min: min,
        max: max,
        title: title,
      ),
    );
  }
}

class _DurationPickerContent extends StatefulWidget {
  final int initialValue;
  final int min;
  final int max;
  final String title;

  const _DurationPickerContent({
    required this.initialValue,
    required this.min,
    required this.max,
    required this.title,
  });

  @override
  State<_DurationPickerContent> createState() => _DurationPickerContentState();
}

class _DurationPickerContentState extends State<_DurationPickerContent> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              widget.title,
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Current value
            Text(
              '${_currentValue.toInt()} ${AppStrings.minutesUnit}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Slider
            Slider(
              value: _currentValue,
              min: widget.min.toDouble(),
              max: widget.max.toDouble(),
              divisions: widget.max - widget.min,
              activeColor: AppColors.accentPrimary,
              inactiveColor: AppColors.timerRingBg,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
              },
            ),
            // Min / max labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.min}${AppStrings.minutesUnit}',
                  style: AppTextStyles.caption,
                ),
                Text(
                  '${widget.max}${AppStrings.minutesUnit}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_currentValue.toInt()),
                    child: const Text(AppStrings.confirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
