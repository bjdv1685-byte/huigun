import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../models/plan_item.dart';

class PlanRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<List<PlanItem>> getAllActive() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DB.plans,
      where: '${DB.pIsDeleted} = 0',
      orderBy: '${DB.createdAt} DESC',
    );
    return maps.map((m) => PlanItem.fromMap(m)).toList();
  }

  Future<PlanItem> insert({
    required String content,
    PlanItemType itemType = PlanItemType.todo,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final plan = PlanItem(
      id: _uuid.v4(),
      content: content,
      itemType: itemType,
      createdAt: now,
    );
    await db.insert(DB.plans, plan.toMap());
    return plan;
  }

  Future<void> updateContent(String id, String content) async {
    final db = await _dbHelper.database;
    await db.update(
      DB.plans,
      {DB.pContent: content},
      where: '${DB.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleComplete(String id, bool isCompleted) async {
    final db = await _dbHelper.database;
    await db.update(
      DB.plans,
      {
        DB.pIsCompleted: isCompleted ? 1 : 0,
        DB.pCompletedAt: isCompleted
            ? DateTime.now().millisecondsSinceEpoch
            : null,
      },
      where: '${DB.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      DB.plans,
      {DB.pIsDeleted: 1},
      where: '${DB.id} = ?',
      whereArgs: [id],
    );
  }
}
