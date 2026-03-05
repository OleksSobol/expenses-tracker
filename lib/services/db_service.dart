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
        // Transactions table
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            categoryId INTEGER,
            date TEXT NOT NULL,
            note TEXT,
            billId INTEGER
          )
        ''');

        // Bills table with all required fields
        await db.execute('''
          CREATE TABLE bills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            amount REAL NOT NULL,
            frequency TEXT NOT NULL,
            nextDueDate TEXT NOT NULL,
            autopay INTEGER NOT NULL DEFAULT 0,
            categoryId INTEGER,
            notes TEXT,
            lastPaidDate TEXT,
            isPaid INTEGER NOT NULL DEFAULT 0,
            link TEXT
          )
        ''');

        // Categories table
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT,
            color TEXT
          )
        ''');
      },
    );
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.insert(table, data);
    } catch (e) {
      throw Exception('Failed to insert data into $table: $e');
    }
  }

  Future<void> update(String table, int id, Map<String, dynamic> values) async {
    try {
      final db = await database;
      final rowsAffected = await db.update(table, values, where: 'id = ?', whereArgs: [id]);
      if (rowsAffected == 0) {
        throw Exception('No record found with id $id in table $table');
      }
    } catch (e) {
      throw Exception('Failed to update record in $table: $e');
    }
  }

  Future<int> delete(String table, int id) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(table, where: 'id = ?', whereArgs: [id]);
      if (rowsAffected == 0) {
        throw Exception('No record found with id $id in table $table');
      }
      return rowsAffected;
    } catch (e) {
      throw Exception('Failed to delete record from $table: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    try {
      final db = await database;
      return await db.query(table, orderBy: 'id DESC');
    } catch (e) {
      throw Exception('Failed to query data from $table: $e');
    }
  }

  Future<void> clearTable(String table) async {
    try {
      final db = await database;
      await db.delete(table);
    } catch (e) {
      throw Exception('Failed to clear table $table: $e');
    }
  }
}