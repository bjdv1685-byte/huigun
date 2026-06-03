import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/plan_item.dart';

class PlanItemTile extends StatelessWidget {
  final PlanItem item;
  final ValueChanged<bool>? onToggle;
  final ValueChanged<String>? onDelete;
  final void Function(String id, String content)? onEdit;

  const PlanItemTile({
    super.key,
    required this.item,
    this.onToggle,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isTodo = item.itemType == PlanItemType.todo;
    final completed = item.isCompleted;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: isTodo
          ? SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: completed,
                onChanged: (value) {
                  if (value != null && onToggle != null) {
                    onToggle!(value);
                  }
                },
                activeColor: AppColors.accentSuccess,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
          : null,
      title: Text(
        item.content,
        style: TextStyle(
          decoration: completed ? TextDecoration.lineThrough : null,
          color: completed ? AppColors.textSecondary : AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        color: AppColors.textSecondary,
        onPressed: () => _confirmDelete(context),
      ),
      onTap: () {
        if (!isTodo && onEdit != null) {
          _showEditDialog(context);
        }
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text('确定删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete?.call(item.id);
            },
            child: const Text(
              AppStrings.confirm,
              style: TextStyle(color: AppColors.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: item.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑备忘录'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '编辑内容...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty) {
                onEdit?.call(item.id, newContent);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
