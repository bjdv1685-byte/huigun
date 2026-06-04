import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_durations.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../data/models/quote.dart';
import '../../data/repositories/quote_repository.dart';
import 'providers/settings_provider.dart';
import 'widgets/duration_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // ── Quotes management dialog ─────────────────────────────────────────

  void _showQuotesDialog(BuildContext context) {
    final quoteRepo = QuoteRepository();
    showDialog(
      context: context,
      builder: (ctx) => _QuotesDialog(repo: quoteRepo),
    );
  }

  // ── Section header helper ────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: AppTextStyles.sectionHeader),
    );
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final focusMinutes =
        settingsAsync.value?.focusDurationMinutes ?? 25;
    final breakMinutes =
        settingsAsync.value?.breakDurationMinutes ?? 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabSettings),
      ),
      body: ListView(
        children: [
          // ── 计时设置 ──
          _sectionHeader(AppStrings.timerSettings),
          ListTile(
            leading:
                const Icon(Icons.timer, color: AppColors.accentPrimary),
            title: const Text(AppStrings.focusDuration),
            trailing: Text(
              '$focusMinutes ${AppStrings.minutesUnit}',
              style: AppTextStyles.caption,
            ),
            onTap: () async {
              final result = await DurationPicker.show(
                context: context,
                initialValue: focusMinutes,
                min: AppDurations.minFocusMinutes,
                max: AppDurations.maxFocusMinutes,
                title: AppStrings.focusDuration,
              );
              if (result != null) {
                ref
                    .read(settingsProvider.notifier)
                    .setFocusDuration(result);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.free_breakfast,
                color: AppColors.accentSuccess),
            title: const Text(AppStrings.breakDuration),
            trailing: Text(
              '$breakMinutes ${AppStrings.minutesUnit}',
              style: AppTextStyles.caption,
            ),
            onTap: () async {
              final result = await DurationPicker.show(
                context: context,
                initialValue: breakMinutes,
                min: AppDurations.minBreakMinutes,
                max: AppDurations.maxBreakMinutes,
                title: AppStrings.breakDuration,
              );
              if (result != null) {
                ref
                    .read(settingsProvider.notifier)
                    .setBreakDuration(result);
              }
            },
          ),

          const Divider(),

          // ── 管理 ──
          _sectionHeader(AppStrings.management),
          ListTile(
            leading: const Icon(Icons.category,
                color: AppColors.accentPrimary),
            title: const Text(AppStrings.categoryManagement),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
            onTap: () => context.push('/settings/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.format_quote,
                color: AppColors.accentPrimary),
            title: const Text(AppStrings.quotesManagement),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
            onTap: () => _showQuotesDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.notifications,
                color: AppColors.accentPrimary),
            title: const Text(AppStrings.reminderSettings),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
            onTap: () => context.push('/settings/reminders'),
          ),

          const Divider(),

          // ── 其他 ──
          _sectionHeader(AppStrings.other),
          ListTile(
            leading: const Icon(Icons.info_outline,
                color: AppColors.accentPrimary),
            title: const Text(AppStrings.about),
            trailing: Text(
              AppStrings.appVersion,
              style: AppTextStyles.caption,
            ),
            onTap: () => context.push('/settings/about'),
          ),
        ],
      ),
    );
  }
}

// ─── Quotes dialog ───────────────────────────────────────────────────────

class _QuotesDialog extends StatefulWidget {
  final QuoteRepository repo;
  const _QuotesDialog({required this.repo});

  @override
  State<_QuotesDialog> createState() => _QuotesDialogState();
}

class _QuotesDialogState extends State<_QuotesDialog> {
  late Future<List<Quote>> _quotesFuture;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quotesFuture = widget.repo.getAll();
  }

  void _refresh() {
    setState(() {
      _quotesFuture = widget.repo.getAll();
    });
  }

  Future<void> _addQuote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await widget.repo.insertCustomQuote(text);
    _controller.clear();
    _refresh();
  }

  Future<void> _deleteQuote(Quote quote) async {
    if (quote.id == null) return;
    await widget.repo.delete(quote.id!);
    _refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              AppStrings.quotesManagement,
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Add bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: 15,
                    decoration: InputDecoration(
                      hintText: AppStrings.quoteHint,
                      counterText: '',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addQuote(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppColors.accentPrimary),
                  onPressed: _addQuote,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Quote list
            Flexible(
              child: FutureBuilder<List<Quote>>(
                future: _quotesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final quotes = snapshot.data ?? [];
                  if (quotes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        '还没有激励语',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: quotes.length,
                      itemBuilder: (_, i) {
                        final q = quotes[i];
                        return ListTile(
                          dense: true,
                          title: Text(q.text, style: AppTextStyles.bodyText),
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: AppColors.textSecondary),
                            onPressed: () => _deleteQuote(q),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
