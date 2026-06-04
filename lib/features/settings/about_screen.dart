import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.about),
      ),
      body: Column(
        children: [
          // Centered content
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer,
                    size: 80,
                    color: AppColors.accentPrimary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.appName,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.appVersion,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '一款专注学习的番茄钟计时器',
                    style: AppTextStyles.bodyText,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '数据完全存储在本地，无需网络',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),

          // Footer
          const Padding(
            padding: EdgeInsets.only(bottom: 32),
            child: Text(
              'Made with ❤️',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
