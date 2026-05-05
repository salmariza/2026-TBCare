import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'tbcare.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE medicine (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            dosage TEXT,
            schedule TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE monitoring (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicine_id INTEGER,
            status TEXT,
            date TEXT
          )
        ''');
      },
    );
  }
}