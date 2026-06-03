import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'database_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/pomodoro.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DB.categories} (
        ${DB.id} TEXT PRIMARY KEY,
        ${DB.catName} TEXT NOT NULL,
        ${DB.catColorValue} INTEGER NOT NULL,
        ${DB.catSortOrder} INTEGER NOT NULL DEFAULT 0,
        ${DB.catIsDefault} INTEGER NOT NULL DEFAULT 0,
        ${DB.catIsDeleted} INTEGER NOT NULL DEFAULT 0,
        ${DB.createdAt} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DB.timerSessions} (
        ${DB.id} TEXT PRIMARY KEY,
        ${DB.tsCategoryId} TEXT NOT NULL,
        ${DB.tsStartTime} INTEGER NOT NULL,
        ${DB.tsEndTime} INTEGER,
        ${DB.tsDurationSeconds} INTEGER NOT NULL DEFAULT 0,
        ${DB.tsSessionType} INTEGER NOT NULL DEFAULT 0,
        ${DB.tsStatus} INTEGER NOT NULL DEFAULT 0,
        ${DB.createdAt} INTEGER NOT NULL,
        FOREIGN KEY (${DB.tsCategoryId}) REFERENCES ${DB.categories}(${DB.id})
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_sessions_category
      ON ${DB.timerSessions}(${DB.tsCategoryId})
    ''');

    await db.execute('''
      CREATE INDEX idx_sessions_time
      ON ${DB.timerSessions}(${DB.tsStartTime})
    ''');

    await db.execute('''
      CREATE TABLE ${DB.quotes} (
        ${DB.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DB.qText} TEXT NOT NULL,
        ${DB.qQuarterLabel} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DB.quoteShownHistory} (
        ${DB.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DB.qshQuoteId} INTEGER NOT NULL,
        ${DB.qshShownAt} INTEGER NOT NULL,
        FOREIGN KEY (${DB.qshQuoteId}) REFERENCES ${DB.quotes}(${DB.id})
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_quote_shown
      ON ${DB.quoteShownHistory}(${DB.qshQuoteId}, ${DB.qshShownAt})
    ''');

    await db.execute('''
      CREATE TABLE ${DB.plans} (
        ${DB.id} TEXT PRIMARY KEY,
        ${DB.pContent} TEXT NOT NULL,
        ${DB.pItemType} INTEGER NOT NULL DEFAULT 0,
        ${DB.pIsCompleted} INTEGER NOT NULL DEFAULT 0,
        ${DB.createdAt} INTEGER NOT NULL,
        ${DB.pCompletedAt} INTEGER,
        ${DB.pIsDeleted} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DB.notificationConfigs} (
        ${DB.id} TEXT PRIMARY KEY,
        ${DB.ncNotifType} INTEGER NOT NULL,
        ${DB.ncIsEnabled} INTEGER NOT NULL DEFAULT 1,
        ${DB.ncTimeOfDay} TEXT,
        ${DB.ncMessage} TEXT,
        ${DB.createdAt} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DB.appSettings} (
        ${DB.asKey} TEXT PRIMARY KEY,
        ${DB.asValue} TEXT NOT NULL
      )
    ''');

    await _insertSeedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations here
  }

  Future<void> _insertSeedData(Database db) async {
    final uuid = const Uuid();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Default categories
    final categories = [
      {'name': '资料分析', 'color': 0xFFE03131, 'order': 0},
      {'name': '逻辑判断', 'color': 0xFFC2255C, 'order': 1},
      {'name': '言语理解', 'color': 0xFF9C36B5, 'order': 2},
      {'name': '数量关系', 'color': 0xFF6741D9, 'order': 3},
      {'name': '常识判断', 'color': 0xFF3B5BDB, 'order': 4},
      {'name': '申论/写作', 'color': 0xFF1C7ED6, 'order': 5},
      {'name': '复盘总结', 'color': 0xFF0CA678, 'order': 6},
      {'name': '运动', 'color': 0xFFF08C00, 'order': 7},
    ];

    for (final cat in categories) {
      await db.insert(DB.categories, {
        DB.id: uuid.v4(),
        DB.catName: cat['name'],
        DB.catColorValue: cat['color'],
        DB.catSortOrder: cat['order'],
        DB.catIsDefault: 1,
        DB.catIsDeleted: 0,
        DB.createdAt: now,
      });
    }

    // 90 motivational quotes
    const quotes = [
      '今天的努力是明天的底气',
      '专注当下，未来可期',
      '一分耕耘，一分收获',
      '坚持就是胜利',
      '时间花在哪里，成就就在哪里',
      '慢慢来，比较快',
      '每一步都算数',
      '自律即自由',
      '不积跬步，无以至千里',
      '水滴石穿，绳锯木断',
      '你比你想象的更强大',
      '行动是治愈焦虑的良药',
      '每一个清晨都是新开始',
      '成功的路上并不拥挤',
      '心静自然成',
      '你的坚持终将美好',
      '做时间的朋友',
      '少壮工夫老始成',
      '积土成山，风雨兴焉',
      '志之所趋，无远弗届',
      '天道酬勤，功不唐捐',
      '日日行，不怕千万里',
      '常常做，不怕千万事',
      '勤能补拙是良训',
      '宝剑锋从磨砺出',
      '梅花香自苦寒来',
      '千里之行始于足下',
      '业精于勤荒于嬉',
      '行成于思毁于随',
      '锲而不舍，金石可镂',
      '加油，你能行',
      '保持专注，保持热爱',
      '今天也是元气满满的一天',
      '每一次努力都算数',
      '未来属于奋斗者',
      '静下心来，做好当下',
      '人生没有白走的路',
      '把简单的事做到极致',
      '全力以赴，不留遗憾',
      '你的努力，时间看得见',
      '不放弃就是最大的天赋',
      '先完成，再完美',
      '学习使人进步',
      '知识改变命运',
      '厚积而薄发',
      '仰望星空，脚踏实地',
      '心之所向，素履以往',
      '生如逆旅，一苇以航',
      '乘风破浪会有时',
      '直挂云帆济沧海',
      '路漫漫其修远兮',
      '吾将上下而求索',
      '学如逆水行舟',
      '不进则退',
      '温故而知新',
      '学而不思则罔',
      '思而不学则殆',
      '知之为知之，不知为不知',
      '三人行必有我师',
      '敏而好学，不耻下问',
      '博学之，审问之',
      '慎思之，明辨之',
      '笃行之',
      '天下无难事，只怕有心人',
      '你若盛开，蝴蝶自来',
      '心有多大，舞台就有多大',
      '种一棵树最好的时间是十年前',
      '其次是现在',
      '没有比脚更长的路',
      '没有比人更高的山',
      '所有的努力都会发光',
      '人生最精彩的不是成功的瞬间',
      '而是坚持的每一个过程',
      '不怕万人阻挡，只怕自己投降',
      '你的坚持，终将美好',
      '星光不问赶路人',
      '时光不负有心人',
      '让优秀成为一种习惯',
      '在坚持中遇见更好的自己',
      '与其羡慕别人，不如自己努力',
      '每一次发奋努力的背后',
      '必有加倍的赏赐',
      '向着月亮出发吧',
      '即使不能到达，也能站在群星之中',
      '热爱可抵岁月漫长',
      '把自己活成一束光',
      '前方有光，脚下有路',
      '一天一个小目标',
      '点滴积累，汇成大海',
      '不负韶华，不负自己',
    ];

    for (int i = 0; i < quotes.length; i++) {
      await db.insert(DB.quotes, {
        DB.qText: quotes[i],
        // Distribute across Q1-Q4 roughly evenly
        DB.qQuarterLabel: '2026Q${1 + (i % 4)}',
      });
    }

    // Default settings
    await db.insert(DB.appSettings, {
      DB.asKey: DB.settingFocusDuration,
      DB.asValue: '25',
    });
    await db.insert(DB.appSettings, {
      DB.asKey: DB.settingBreakDuration,
      DB.asValue: '5',
    });

    // Default notification configs
    await db.insert(DB.notificationConfigs, {
      DB.id: uuid.v4(),
      DB.ncNotifType: 0, // scheduled
      DB.ncIsEnabled: 1,
      DB.ncTimeOfDay: '09:00',
      DB.ncMessage: '该开始学习啦！',
      DB.createdAt: now,
    });
    await db.insert(DB.notificationConfigs, {
      DB.id: uuid.v4(),
      DB.ncNotifType: 1, // timer end
      DB.ncIsEnabled: 1,
      DB.ncTimeOfDay: null,
      DB.ncMessage: '计时结束，休息一下吧~',
      DB.createdAt: now,
    });
    await db.insert(DB.notificationConfigs, {
      DB.id: uuid.v4(),
      DB.ncNotifType: 2, // review
      DB.ncIsEnabled: 1,
      DB.ncTimeOfDay: '21:00',
      DB.ncMessage: '今天学习了什么？回顾一下吧',
      DB.createdAt: now,
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
