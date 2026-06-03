import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/plan_item.dart';
import 'plan_item_tile.dart';

class TodoList extends StatelessWidget {
  final List<PlanItem> allItems;
  final void Function(String id, bool value)? onToggle;
  final void Function(String id)? onDelete;

  const TodoList({
    super.key,
    required this.allItems,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final todos = allItems
        .where((item) => item.itemType == PlanItemType.todo)
        .toList();

    if (todos.isEmpty) {
      return const EmptyState(
        icon: Icons.checklist_outlined,
        message: AppStrings.noPlans,
      );
    }

    final pending = todos.where((t) => !t.isCompleted).toList();
    final completed = todos.where((t) => t.isCompleted).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: pending.length + completed.length,
      itemBuilder: (context, index) {
        final isCompletedSection = index >= pending.length;
        final item = isCompletedSection
            ? completed[index - pending.length]
            : pending[index];

        final tile = PlanItemTile(
          item: item,
          onToggle: (value) => onToggle?.call(item.id, value),
          onDelete: (id) => onDelete?.call(id),
        );

        if (isCompletedSection) {
          return Opacity(
            opacity: 0.6,
            child: tile,
          );
        }

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: AppColors.accentPrimary,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete?.call(item.id),
          child: tile,
        );
      },
    );
  }
}
