import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'entries.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            mood TEXT,
            mood_value INTEGER,
            emoji TEXT,
            content TEXT,
            type TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ai_insights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            period TEXT,
            content TEXT,
            created_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE profile (
            id INTEGER PRIMARY KEY,
            name TEXT,
            avatar TEXT,
            theme TEXT,
            language TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertEntry(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('entries', data);
  }

  static Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await database;
    return await db.query('entries', orderBy: 'date DESC');
  }

  static Future<int> updateEntry(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('entries', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getEntriesByDate(
    String dateString,
  ) async {
    final db = await database;
    return await db.query(
      'entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
      orderBy: 'date DESC',
    );
  }
}
