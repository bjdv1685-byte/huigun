import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../data/models/category.dart';
import 'providers/category_list_provider.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.categoryManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppStrings.addCategory,
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noCategories,
                style: AppTextStyles.caption,
              ),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              _onReorder(categories, oldIndex, newIndex);
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final double elevation =
                      Tween<double>(begin: 0, end: 4).evaluate(animation);
                  return Material(
                    elevation: elevation,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryListTile(
                key: ValueKey(category.id),
                index: index,
                category: category,
                onEdit: () => _showAddEditDialog(category: category),
                onDelete: category.isDefault
                    ? null
                    : () => _confirmDelete(category),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('加载失败：$err', style: AppTextStyles.caption)),
      ),
    );
  }

  // ── Reorder logic ────────────────────────────────────────────────────

  void _onReorder(List<Category> list, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;

    final items = List<Category>.from(list);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    final orderedIds = items.map((c) => c.id).toList();
    ref.read(categoryListProvider.notifier).reorder(orderedIds);
  }

  // ── Add / Edit dialog ────────────────────────────────────────────────

  void _showAddEditDialog({Category? category}) {
    final isEdit = category != null;
    final nameController =
        TextEditingController(text: category?.name ?? '');
    int selectedColor =
        category?.colorValue ?? AppColors.customColorPool[0].toARGB32();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEdit
                          ? AppStrings.editCategory
                          : AppStrings.addCategory,
                      style: AppTextStyles.cardTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: '分类名称',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    Text('选择颜色', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppColors.customColorPool.map((color) {
                        final isSelected = color.toARGB32() == selectedColor;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color.toARGB32();
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.textPrimary,
                                      width: 3,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text(AppStrings.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final name = nameController.text.trim();
                              if (name.isEmpty) return;
                              if (isEdit && category != null) {
                                ref
                                    .read(categoryListProvider.notifier)
                                    .editCategory(category.copyWith(
                                      name: name,
                                      colorValue: selectedColor,
                                    ));
                              } else {
                                ref
                                    .read(categoryListProvider.notifier)
                                    .addCategory(name, selectedColor);
                              }
                              Navigator.of(ctx).pop();
                            },
                            child: const Text(AppStrings.confirm),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Delete confirmation ──────────────────────────────────────────────

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: Text('确定要删除 "${category.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(categoryListProvider.notifier)
                  .deleteCategory(category.id);
              Navigator.of(ctx).pop();
            },
            child: const Text(AppStrings.delete,
                style: TextStyle(color: AppColors.accentPrimary)),
          ),
        ],
      ),
    );
  }
}

// ─── Category tile widget ──────────────────────────────────────────────────

class _CategoryListTile extends StatelessWidget {
  final int index;
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _CategoryListTile({
    super.key,
    required this.index,
    required this.category,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.intToColor(category.colorValue);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: const Icon(
                  Icons.drag_handle,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),

              // Color dot
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Text(
                  category.name,
                  style: AppTextStyles.bodyText,
                ),
              ),

              // Delete button (custom categories only)
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 20, color: AppColors.textSecondary),
                  onPressed: onDelete,
                  tooltip: AppStrings.delete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
