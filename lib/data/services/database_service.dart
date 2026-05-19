import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _db;

  DatabaseService._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'tbcare.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT,
            age INTEGER,
            gender TEXT,
            profile_image TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE medicine (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            name TEXT,
            dosage TEXT,
            schedule TEXT,
            treatment_phase TEXT,
            frequency TEXT,
            FOREIGN KEY (user_id) REFERENCES user (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE monitoring (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicine_id INTEGER,
            status TEXT,
            date TEXT,
            taken_at TEXT,
            note TEXT,
            FOREIGN KEY (medicine_id) REFERENCES medicine (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE treatment_plan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            start_date TEXT,
            end_date TEXT,
            total_days INTEGER,
            current_day INTEGER,
            status TEXT,
            reminder_enabled INTEGER,
            FOREIGN KEY (user_id) REFERENCES user (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE symptom (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE monitoring_symptom (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            monitoring_id INTEGER,
            symptom_id INTEGER,
            FOREIGN KEY (monitoring_id) REFERENCES monitoring (id),
            FOREIGN KEY (symptom_id) REFERENCES symptom (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE missed_dose (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicine_id INTEGER,
            missed_date TEXT,
            resolved INTEGER,
            doctor_contacted INTEGER,
            note TEXT,
            FOREIGN KEY (medicine_id) REFERENCES medicine (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE badge (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            required_streak INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE user_badge (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            badge_id INTEGER,
            earned_at TEXT,
            FOREIGN KEY (user_id) REFERENCES user (id),
            FOREIGN KEY (badge_id) REFERENCES badge (id)
          )
        ''');
      },
    );
  }
}
