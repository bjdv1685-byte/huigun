import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/category_repository.dart';

/// Repository provider for CategoryRepository.
final categoryRepoProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// AsyncNotifier that provides the current list of active categories.
final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<Category>>(
  CategoryListNotifier.new,
);

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repo = ref.read(categoryRepoProvider);
    return repo.getAllActive();
  }

  Future<void> refresh() async {
    final repo = ref.read(categoryRepoProvider);
    state = AsyncData(await repo.getAllActive());
  }

  Future<Category> addCategory(String name, int colorValue) async {
    final repo = ref.read(categoryRepoProvider);
    final cat = await repo.insert(name, colorValue);
    await refresh();
    return cat;
  }

  Future<void> editCategory(Category category) async {
    final repo = ref.read(categoryRepoProvider);
    await repo.update(category);
    await refresh();
  }

  Future<void> deleteCategory(String id) async {
    final repo = ref.read(categoryRepoProvider);
    await repo.softDelete(id);
    await refresh();
  }

  Future<void> reorder(List<String> orderedIds) async {
    final repo = ref.read(categoryRepoProvider);
    await repo.reorder(orderedIds);
    await refresh();
  }
}
