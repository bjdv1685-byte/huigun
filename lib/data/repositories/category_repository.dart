import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<List<Category>> getAllActive() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DB.categories,
      where: '${DB.catIsDeleted} = 0',
      orderBy: '${DB.catSortOrder} ASC',
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<Category?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DB.categories,
      where: '${DB.id} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<Category> insert(String name, int colorValue) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Get max sort order
    final result = await db.rawQuery(
      'SELECT MAX(${DB.catSortOrder}) as max_order FROM ${DB.categories} WHERE ${DB.catIsDeleted} = 0',
    );
    final maxOrder = (result.first['max_order'] as int?) ?? -1;
    final category = Category(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      sortOrder: maxOrder + 1,
      isDefault: false,
      createdAt: now,
    );
    await db.insert(DB.categories, category.toMap());
    return category;
  }

  Future<void> update(Category category) async {
    final db = await _dbHelper.database;
    await db.update(
      DB.categories,
      category.toMap(),
      where: '${DB.id} = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> softDelete(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      DB.categories,
      {DB.catIsDeleted: 1},
      where: '${DB.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> reorder(List<String> orderedIds) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      batch.update(
        DB.categories,
        {DB.catSortOrder: i},
        where: '${DB.id} = ?',
        whereArgs: [orderedIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }
}
