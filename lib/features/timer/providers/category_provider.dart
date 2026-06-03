import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/data/repositories/category_repository.dart';
import 'package:pomodoro_app/data/models/category.dart';

/// Provider for CategoryRepository so it can be injected via ref.read.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repo = ref.read(categoryRepositoryProvider);
    return repo.getAllActive();
  }

  Future<void> addCategory(String name, int colorValue) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.insert(name, colorValue);
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(String id) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.softDelete(id);
    ref.invalidateSelf();
  }

  Future<void> updateCategory(Category category) async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.update(category);
    ref.invalidateSelf();
  }
}

final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<Category>>(
  CategoryListNotifier.new,
);
