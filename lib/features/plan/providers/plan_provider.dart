import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/plan_item.dart';
import '../../../data/repositories/plan_repository.dart';

final planRepoProvider = Provider<PlanRepository>((ref) {
  return PlanRepository();
});

final planListProvider =
    AsyncNotifierProvider<PlanNotifier, List<PlanItem>>(PlanNotifier.new);

class PlanNotifier extends AsyncNotifier<List<PlanItem>> {
  @override
  Future<List<PlanItem>> build() async {
    final repo = ref.read(planRepoProvider);
    return await repo.getAllActive();
  }

  Future<void> addTodo(String content) async {
    final repo = ref.read(planRepoProvider);
    await repo.insert(content: content, itemType: PlanItemType.todo);
    ref.invalidateSelf();
  }

  Future<void> addMemo(String content) async {
    final repo = ref.read(planRepoProvider);
    await repo.insert(content: content, itemType: PlanItemType.memo);
    ref.invalidateSelf();
  }

  Future<void> toggleComplete(String id, bool isCompleted) async {
    final repo = ref.read(planRepoProvider);
    await repo.toggleComplete(id, isCompleted);
    ref.invalidateSelf();
  }

  Future<void> updateContent(String id, String content) async {
    final repo = ref.read(planRepoProvider);
    await repo.updateContent(id, content);
    ref.invalidateSelf();
  }

  Future<void> deleteItem(String id) async {
    final repo = ref.read(planRepoProvider);
    await repo.softDelete(id);
    ref.invalidateSelf();
  }
}
