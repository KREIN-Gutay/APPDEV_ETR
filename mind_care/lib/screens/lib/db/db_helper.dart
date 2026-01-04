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
      // Incremented version to 4 to handle the new audioPath column
      version: 4,
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

        // Note table with audioPath included for fresh installs
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            dateTime TEXT NOT NULL,
            audioPath TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              dateTime TEXT NOT NULL
            )
          ''');
        }

        // Upgrade for version 4 adds the audioPath column to existing users
        if (oldVersion < 4) {
          var columns = await db.rawQuery('PRAGMA table_info(notes)');
          var hasAudioPath = columns.any(
            (column) => column['name'] == 'audioPath',
          );
          if (!hasAudioPath) {
            await db.execute('ALTER TABLE notes ADD COLUMN audioPath TEXT');
          }
        }
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

  // --- NOTE METHODS ---

  static Future<int> insertNote(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'notes',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  static Future<int> updateNote(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('notes', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
