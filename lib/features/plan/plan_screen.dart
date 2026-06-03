import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'providers/plan_provider.dart';
import 'widgets/memo_editor.dart';
import 'widgets/todo_list.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final _todoController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _addTodo() {
    final text = _todoController.text.trim();
    if (text.isNotEmpty) {
      ref.read(planListProvider.notifier).addTodo(text);
      _todoController.clear();
    }
  }

  void _saveMemo(String content) {
    ref.read(planListProvider.notifier).addMemo(content);
  }

  void _toggleComplete(String id, bool isCompleted) {
    ref.read(planListProvider.notifier).toggleComplete(id, isCompleted);
  }

  void _deleteItem(String id) {
    ref.read(planListProvider.notifier).deleteItem(id);
  }

  void _editMemo(String id, String content) {
    ref.read(planListProvider.notifier).updateContent(id, content);
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('计划'),
      ),
      body: planAsync.when(
        data: (items) => Column(
          children: [
            // Memo editor card at top
            MemoEditor(onSave: _saveMemo),
            const Divider(),
            // Todo list takes remaining space
            Expanded(
              child: TodoList(
                allItems: items,
                onToggle: _toggleComplete,
                onDelete: _deleteItem,
              ),
            ),
            // Add todo bar fixed at bottom
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _todoController,
                        decoration: const InputDecoration(
                          hintText: AppStrings.addTodo,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _addTodo(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addTodo,
                      icon: const Icon(Icons.add_circle, color: AppColors.accentPrimary),
                      iconSize: 32,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            '加载失败: $error',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
