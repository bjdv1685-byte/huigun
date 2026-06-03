import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// 计时器数字：大号
  static const TextStyle timerDigit = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.timerDigitFocus,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: 4,
  );

  /// 计时器分类名
  static const TextStyle timerCategory = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// 启动页激励语
  static const TextStyle quoteLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// 卡片标题
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 正文
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// 辅助说明文字
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 统计数字
  static const TextStyle statNumber = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// 统计标签
  static const TextStyle statLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// 分类胶囊文字
  static const TextStyle categoryChip = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Tab 标签
  static const TextStyle tabLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  /// 按钮文字
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// 设置分组标题
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
}
