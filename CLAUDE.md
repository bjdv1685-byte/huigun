# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

个人番茄时钟 Android APP — Flutter 开发，本地 SQLite 存储，完全离线，不上架商店。APK 直接安装使用。

## 构建与开发命令

```bash
# 安装依赖
flutter pub get

# 静态分析（零错误基线）
flutter analyze

# 构建 Release APK
flutter build apk --release

# APK 输出位置
build/app/outputs/flutter-apk/app-release.apk

# 运行测试
flutter test

# 运行单个测试文件
flutter test test/widget_test.dart
```

环境变量需要设置（Windows下）：
```bash
export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-17.0.17.10-hotspot"
export PATH="$JAVA_HOME/bin:/c/tools/flutter/bin:$PATH"
```

## 技术栈

| 层 | 技术 |
|----|------|
| 框架 | Flutter 3.41 + Material 3 |
| 状态管理 | flutter_riverpod (AsyncNotifier / StateNotifier) |
| 路由 | go_router + StatefulShellRoute.indexedStack |
| 数据库 | sqflite（6 张表，单例 DatabaseHelper） |
| 图表 | fl_chart（饼图 + 折线图） |
| 通知 | flutter_local_notifications + android_alarm_manager_plus |
| ID | uuid v4 |
| 主题 | Material 3 ColorScheme.fromSeed，撞色设计 |

## 架构分层

```
lib/
├── main.dart                    # 入口：初始化 DB/通知 → runApp(ProviderScope)
├── app.dart                     # MaterialApp.router + AppTheme.light
├── router/app_router.dart       # GoRouter：StatefulShellRoute（4 个底部 Tab）
├── core/                        # 跨 feature 共享基础设施
│   ├── constants/               # AppColors / AppStrings / AppDurations
│   ├── theme/                   # AppTheme（Material3）+ AppTextStyles
│   ├── extensions/              # DateTime / Duration 扩展方法
│   ├── utils/                   # NotificationHelper / DateUtils
│   └── widgets/                 # AppScaffold / LoadingIndicator / EmptyState
├── data/                        # 数据层（与 UI 完全解耦）
│   ├── database/                # DatabaseHelper 单例 + DB 常量（表名/列名）
│   ├── models/                  # Category / TimerSession / Quote / PlanItem / NotificationConfig
│   └── repositories/            # 封装 SQL 查询，返回 model
└── features/                    # 功能模块，feature-first 组织
    ├── splash/                  # 启动页（2秒 + 90条激励语季度轮换）
    ├── timer/                   # 计时器（核心功能）
    ├── statistics/              # 图表分析（饼图/折线图）
    ├── plan/                    # 计划（待办+备忘录）
    ├── settings/                # 设置（时长/分类管理/提醒/关于）
    └── home/                    # 底部导航栏壳
```

## 数据流模式

```
UI (ref.watch) ← StateNotifier/AsyncNotifier ← Repository ← DatabaseHelper ← SQLite
```

- 数据层通过 Repository 封装所有 SQL 查询
- Provider 层通过 Riverpod 暴露状态给 UI
- TimerService 是纯 Dart 类（不依赖 Flutter），使用 `Timer.periodic` + `StreamController`
- 计时结束 → sessionRepo 写入 → 通知弹出 → statisticsProvider 自动刷新图表

## 数据库（6 张表，v1）

| 表 | 用途 | 主键 |
|----|------|------|
| `categories` | 分类（8个默认 + 自定义） | TEXT UUID |
| `timer_sessions` | 计时记录 | TEXT UUID |
| `quotes` | 90条激励语 | INTEGER AUTO |
| `quote_shown_history` | 季度轮换追踪 | INTEGER AUTO |
| `plans` | 待办/备忘录 | TEXT UUID |
| `notification_configs` | 提醒配置 | TEXT UUID |
| `app_settings` | 键值设置 | TEXT key |

所有 ID 列使用 UUID v4。表名/列名常量集中在 `database_constants.dart` 的 `DB` 类中。

## 路由结构

```
/                    → SplashScreen（2秒后自动跳转）
/home                → HomeScreen（StatefulShellRoute，保留Tab状态）
  /home/timer        → TimerScreen
  /home/statistics   → StatisticsScreen
  /home/plan         → PlanScreen
  /home/settings     → SettingsScreen
/settings/categories → CategoryManagementScreen（root navigator）
/settings/reminders  → ReminderSettingsScreen
/settings/about      → AboutScreen
```

## 主题/颜色

- 主背景 `#F8F9FA`（柔和暖白），卡片纯白
- 计时器专注态 `#E8590C`（深橙红撞色），休息态 `#2F9E44`（绿色）
- 8 个分类各有预设颜色（红/玫红/紫/靛蓝/蓝/亮蓝/青绿/琥珀）
- Material 3 `ColorScheme.fromSeed`，亮色主题

## 迭代版本

当前 v1.0.0。修改 `pubspec.yaml` 中的 `version` 字段即可升级版本号。
