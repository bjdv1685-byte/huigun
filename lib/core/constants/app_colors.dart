import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── 基础色板 ──
  /// 主背景：柔和暖白，干净愉悦
  static const Color background = Color(0xFFF8F9FA);

  /// 卡片背景：纯白
  static const Color surface = Color(0xFFFFFFFF);

  /// 主文字：深灰
  static const Color textPrimary = Color(0xFF212529);

  /// 辅助文字：中灰
  static const Color textSecondary = Color(0xFF6C757D);

  /// 边框
  static const Color border = Color(0xFFDEE2E6);

  // ── 强调/撞色 ──
  /// 计时器主色：深橙红（专注时）
  static const Color accentPrimary = Color(0xFFE8590C);

  /// 蓝色：按钮/链接
  static const Color accentSecondary = Color(0xFF1C7ED6);

  /// 绿色：完成/休息态
  static const Color accentSuccess = Color(0xFF2F9E44);

  /// 琥珀色：提醒态
  static const Color accentWarning = Color(0xFFF08C00);

  // ── 计时器专用 ──
  static const Color timerRingBg = Color(0xFFE9ECEF);
  static const Color timerRingFocus = Color(0xFFE8590C);
  static const Color timerRingBreak = Color(0xFF2F9E44);
  static const Color timerDigitFocus = Color(0xFF212529);
  static const Color timerDigitBreak = Color(0xFF2F9E44);

  // ── 分类预设颜色 ──
  static const List<Color> categoryDefaults = [
    Color(0xFFE03131), // 红 — 资料分析
    Color(0xFFC2255C), // 玫红 — 逻辑判断
    Color(0xFF9C36B5), // 紫 — 言语理解
    Color(0xFF6741D9), // 靛蓝 — 数量关系
    Color(0xFF3B5BDB), // 蓝 — 常识判断
    Color(0xFF1C7ED6), // 亮蓝 — 申论/写作
    Color(0xFF0CA678), // 青绿 — 复盘总结
    Color(0xFFF08C00), // 琥珀 — 运动
  ];

  /// 获取分类颜色（按索引循环）
  static Color categoryColor(int index) {
    return categoryDefaults[index % categoryDefaults.length];
  }

  /// 将 Color 转为 int 用于存储
  static int colorToInt(Color color) {
    return color.toARGB32();
  }

  /// 从 int 恢复 Color
  static Color intToColor(int value) {
    return Color(value);
  }

  // ── 自定义分类可选颜色池 ──
  static const List<Color> customColorPool = [
    Color(0xFFE03131),
    Color(0xFFC2255C),
    Color(0xFF9C36B5),
    Color(0xFF6741D9),
    Color(0xFF3B5BDB),
    Color(0xFF1C7ED6),
    Color(0xFF0CA678),
    Color(0xFFF08C00),
    Color(0xFFFD7E14),
    Color(0xFFFCC419),
    Color(0xFF40C057),
    Color(0xFF20C997),
    Color(0xFF15AABF),
    Color(0xFF7950F2),
    Color(0xFFF06595),
    Color(0xFFFF6B6B),
  ];
}
