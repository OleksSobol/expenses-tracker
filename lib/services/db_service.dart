import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            type TEXT,
            categoryId INTEGER,
            date TEXT,
            note TEXT,
            billId INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE bills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            amount REAL,
            frequency TEXT,
            nextDueDate TEXT,
            autopay INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            icon TEXT,
            color TEXT
          )
        ''');
      },
    );
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
  final db = await database;
  try {
    return await db.insert(table, data);
  } catch (e) {
    print('DB Insert Error: $e');
    return -1;
  }
}

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
  
  Future<void> clearTable(String table) async {
  final db = await database;
  await db.delete(table);
  print('$table cleared');
}

}
