import '../database/database_helper.dart';
import '../database/database_constants.dart';
import '../models/quote.dart';

class QuoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String getCurrentQuarterLabel() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    return '${now.year}Q$quarter';
  }

  int getQuarterStartMs(String quarterLabel) {
    final parts = quarterLabel.split('Q');
    final year = int.parse(parts[0]);
    final quarter = int.parse(parts[1]);
    final month = (quarter - 1) * 3 + 1;
    return DateTime(year, month, 1).millisecondsSinceEpoch;
  }

  Future<Quote?> getRandomUnshownQuote() async {
    final db = await _dbHelper.database;
    final quarterLabel = getCurrentQuarterLabel();
    final quarterStart = getQuarterStartMs(quarterLabel);

    // Try to get an unshown quote from current quarter
    var rows = await db.rawQuery('''
      SELECT q.* FROM ${DB.quotes} q
      WHERE q.${DB.qQuarterLabel} = ?
        AND q.${DB.id} NOT IN (
          SELECT ${DB.qshQuoteId} FROM ${DB.quoteShownHistory}
          WHERE ${DB.qshShownAt} >= ?
        )
      ORDER BY RANDOM() LIMIT 1
    ''', [quarterLabel, quarterStart]);

    // If all shown, reset for this quarter
    if (rows.isEmpty) {
      await db.delete(
        DB.quoteShownHistory,
        where: '${DB.qshShownAt} >= ?',
        whereArgs: [quarterStart],
      );
      rows = await db.rawQuery('''
        SELECT * FROM ${DB.quotes}
        WHERE ${DB.qQuarterLabel} = ?
        ORDER BY RANDOM() LIMIT 1
      ''', [quarterLabel]);
    }

    if (rows.isEmpty) return null;
    final quote = Quote.fromMap(rows.first);
    await _markShown(quote.id!);
    return quote;
  }

  Future<void> _markShown(int quoteId) async {
    final db = await _dbHelper.database;
    await db.insert(DB.quoteShownHistory, {
      DB.qshQuoteId: quoteId,
      DB.qshShownAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Allow user to add custom quote
  Future<Quote> insertCustomQuote(String text) async {
    final db = await _dbHelper.database;
    final quarterLabel = getCurrentQuarterLabel();
    final id = await db.insert(DB.quotes, {
      DB.qText: text,
      DB.qQuarterLabel: quarterLabel,
    });
    return Quote(id: id, text: text, quarterLabel: quarterLabel);
  }

  /// Get all quotes
  Future<List<Quote>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(DB.quotes, orderBy: '${DB.id} ASC');
    return maps.map((m) => Quote.fromMap(m)).toList();
  }

  /// Delete a custom quote
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete(DB.quotes, where: '${DB.id} = ?', whereArgs: [id]);
  }
}
