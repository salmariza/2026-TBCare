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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
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
            FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
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
            FOREIGN KEY (medicine_id) REFERENCES medicine (id) ON DELETE CASCADE
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
            FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
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
            FOREIGN KEY (monitoring_id) REFERENCES monitoring (id) ON DELETE CASCADE,
            FOREIGN KEY (symptom_id) REFERENCES symptom (id) ON DELETE CASCADE
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
            FOREIGN KEY (medicine_id) REFERENCES medicine (id) ON DELETE CASCADE
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
            FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE,
            FOREIGN KEY (badge_id) REFERENCES badge (id) ON DELETE CASCADE
          )
        ''');

        await _seedSymptoms(db);
        await _seedBadges(db);
      },
    );
  }

  Future<void> _seedSymptoms(Database db) async {
    final symptoms = [
      {'name': 'Demam', 'description': 'Suhu tubuh di atas 38°C'},
      {'name': 'Batuk berkepanjangan', 'description': 'Batuk lebih dari 2 minggu'},
      {'name': 'Berat badan turun', 'description': 'Berat badan turun tanpa sebab'},
      {'name': 'Keringat malam', 'description': 'Keringat berlebih di malam hari'},
      {'name': 'Sesak napas', 'description': 'Kesulitan bernapas'},
    ];

    for (final symptom in symptoms) {
      await db.insert('symptom', symptom);
    }
  }

  Future<void> _seedBadges(Database db) async {
    final badges = [
      {
        'title': '1 Minggu Disiplin',
        'description': 'Minum obat 7 hari berturut-turut',
        'required_streak': 7,
      },
      {
        'title': '2 Minggu Disiplin',
        'description': 'Minum obat 14 hari berturut-turut',
        'required_streak': 14,
      },
      {
        'title': '1 Bulan Disiplin',
        'description': 'Minum obat 30 hari berturut-turut',
        'required_streak': 30,
      },
    ];

    for (final badge in badges) {
      await db.insert('badge', badge);
    }
  }

  // ─── USER ───────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;

    final results = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;

    final results = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final db = await database;

    final results = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await database;

    return db.insert(
      'user',
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;

    await db.update(
      'user',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── TREATMENT PLAN ─────────────────────────────────────

  Future<Map<String, dynamic>?> getTreatmentPlan(int userId) async {
    final db = await database;

    final results = await db.query(
      'treatment_plan',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertTreatmentPlan(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('treatment_plan', data);
  }

  Future<void> updateTreatmentPlan(int id, Map<String, dynamic> data) async {
    final db = await database;

    await db.update(
      'treatment_plan',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── MEDICINE ───────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMedicines(int userId) async {
    final db = await database;

    return db.query(
      'medicine',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<Map<String, dynamic>?> getMedicineById(int id) async {
    final db = await database;

    final results = await db.query(
      'medicine',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertMedicine(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('medicine', data);
  }

  Future<void> updateMedicine(int id, Map<String, dynamic> data) async {
    final db = await database;

    await db.update(
      'medicine',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMedicine(int id) async {
    final db = await database;

    await db.delete(
      'medicine',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── MONITORING ─────────────────────────────────────────

  Future<Map<String, dynamic>?> getTodayMonitoring(
    int medicineId,
    String date,
  ) async {
    final db = await database;

    final results = await db.query(
      'monitoring',
      where: 'medicine_id = ? AND date = ?',
      whereArgs: [medicineId, date],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertMonitoring(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('monitoring', data);
  }

  Future<void> updateMonitoring(int id, Map<String, dynamic> data) async {
    final db = await database;

    await db.update(
      'monitoring',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getMonitoringHistory(int userId) async {
    final db = await database;

    return db.rawQuery('''
      SELECT m.*, med.name AS medicine_name
      FROM monitoring m
      JOIN medicine med ON m.medicine_id = med.id
      WHERE med.user_id = ?
      ORDER BY m.date DESC, m.taken_at DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getMonitoringDates(
    int userId,
    String status,
  ) async {
    final db = await database;

    return db.rawQuery('''
      SELECT m.date
      FROM monitoring m
      JOIN medicine med ON m.medicine_id = med.id
      WHERE med.user_id = ? AND m.status = ?
      ORDER BY m.date ASC
    ''', [userId, status]);
  }

  // ─── SYMPTOM ────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllSymptoms() async {
    final db = await database;
    return db.query('symptom');
  }

  Future<List<Map<String, dynamic>>> getSymptomsForMonitoring(
    int monitoringId,
  ) async {
    final db = await database;

    return db.rawQuery('''
      SELECT s.*
      FROM symptom s
      JOIN monitoring_symptom ms ON s.id = ms.symptom_id
      WHERE ms.monitoring_id = ?
    ''', [monitoringId]);
  }

  Future<void> insertMonitoringSymptom(
    int monitoringId,
    int symptomId,
  ) async {
    final db = await database;

    await db.insert('monitoring_symptom', {
      'monitoring_id': monitoringId,
      'symptom_id': symptomId,
    });
  }

  Future<void> deleteSymptomsForMonitoring(int monitoringId) async {
    final db = await database;

    await db.delete(
      'monitoring_symptom',
      where: 'monitoring_id = ?',
      whereArgs: [monitoringId],
    );
  }

  // ─── MISSED DOSE ────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMissedDoses(int userId) async {
    final db = await database;

    return db.rawQuery('''
      SELECT md.*, med.name AS medicine_name
      FROM missed_dose md
      JOIN medicine med ON md.medicine_id = med.id
      WHERE med.user_id = ?
      ORDER BY md.missed_date DESC
    ''', [userId]);
  }

  Future<Map<String, dynamic>?> getMissedDoseByDate(
    int medicineId,
    String date,
  ) async {
    final db = await database;

    final results = await db.query(
      'missed_dose',
      where: 'medicine_id = ? AND missed_date = ?',
      whereArgs: [medicineId, date],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertMissedDose(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('missed_dose', data);
  }

  Future<void> updateMissedDose(int id, Map<String, dynamic> data) async {
    final db = await database;

    await db.update(
      'missed_dose',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMissedDose(int id) async {
    final db = await database;

    await db.delete(
      'missed_dose',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── BADGE & STREAK ─────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBadges() async {
    final db = await database;

    return db.query(
      'badge',
      orderBy: 'required_streak ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserBadges(int userId) async {
    final db = await database;

    return db.rawQuery('''
      SELECT b.*, ub.earned_at
      FROM badge b
      JOIN user_badge ub ON b.id = ub.badge_id
      WHERE ub.user_id = ?
      ORDER BY b.required_streak ASC
    ''', [userId]);
  }

  Future<void> insertUserBadge(int userId, int badgeId) async {
    final db = await database;

    final exists = await db.query(
      'user_badge',
      where: 'user_id = ? AND badge_id = ?',
      whereArgs: [userId, badgeId],
      limit: 1,
    );

    if (exists.isEmpty) {
      await db.insert('user_badge', {
        'user_id': userId,
        'badge_id': badgeId,
        'earned_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int> calculateStreak(int userId) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT DISTINCT m.date
      FROM monitoring m
      JOIN medicine med ON m.medicine_id = med.id
      WHERE med.user_id = ? AND m.status = 'taken'
      ORDER BY m.date DESC
    ''', [userId]);

    if (results.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    final takenDates = results.map((r) => r['date'] as String).toSet();

    while (true) {
      final dateStr =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

      if (takenDates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> checkAndAwardBadges(int userId) async {
    final streak = await calculateStreak(userId);
    final badges = await getAllBadges();

    for (final badge in badges) {
      final required = badge['required_streak'] as int;

      if (streak >= required) {
        await insertUserBadge(userId, badge['id'] as int);
      }
    }
  }

  // ─── WEEKLY STATUS ──────────────────────────────────────

  Future<List<String>> getWeekTakenDates(int userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final db = await database;

    final startDate =
        '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';

    final endDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final results = await db.rawQuery('''
      SELECT DISTINCT m.date
      FROM monitoring m
      JOIN medicine med ON m.medicine_id = med.id
      WHERE med.user_id = ?
        AND m.status = 'taken'
        AND m.date >= ?
        AND m.date <= ?
      ORDER BY m.date ASC
    ''', [userId, startDate, endDate]);

    return results.map((r) => r['date'] as String).toList();
  }

  // ─── CLOSE DATABASE ─────────────────────────────────────

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}