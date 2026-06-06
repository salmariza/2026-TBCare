import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _db;

  DatabaseService._init();

  // TODO: set to false to remove dummy data after demo
  static const bool useDummyData = true;

  /// Dummy records (June 1-6) count as valid treatment days in all
  /// business logic. Only Warning Monitoring / missed-dose detection
  /// starts from this date — June 7 onward.
  static const String realDataStartDate = '2026-06-07';

  static List<Map<String, dynamic>> getDummyHistory() {
    const meds = 'Rifampicin 300mg, Isoniazid 300mg, '
        'Pyrazinamide 500mg, Ethambutol 400mg';

    return [
      // June 1, 2026 (Senin) — On Time
      {
        'date': '2026-06-01',
        'status': 'taken',
        'display_status': 'on_time',
        'medicine_name': meds,
        'taken_at': '2026-06-01T07:00:00',
        'note': null,
        'symptoms': <String>[],
        'is_missed_day': false,
      },
      // June 2, 2026 (Selasa) — On Time
      {
        'date': '2026-06-02',
        'status': 'taken',
        'display_status': 'on_time',
        'medicine_name': meds,
        'taken_at': '2026-06-02T07:00:00',
        'note': null,
        'symptoms': <String>[],
        'is_missed_day': false,
      },
      // June 3, 2026 (Rabu) — Late
      {
        'date': '2026-06-03',
        'status': 'taken_late',
        'display_status': 'late',
        'medicine_name': meds,
        'taken_at': '2026-06-03T11:30:12',
        'note': 'Bangun kesiangan, baru sempat minum obat setelah sarapan.',
        'symptoms': <String>['Pusing ringan'],
        'is_missed_day': false,
      },
      // June 4, 2026 (Kamis) — Missed
      {
        'date': '2026-06-04',
        'status': 'missed',
        'display_status': 'missed',
        'medicine_name': meds,
        'taken_at': null,
        'note': null,
        'symptoms': <String>[],
        'is_missed_day': true,
      },
      // June 5, 2026 (Jumat) — On Time
      {
        'date': '2026-06-05',
        'status': 'taken',
        'display_status': 'on_time',
        'medicine_name': meds,
        'taken_at': '2026-06-05T07:00:00',
        'note': null,
        'symptoms': <String>[],
        'is_missed_day': false,
      },
      // June 6, 2026 (Sabtu) — On Time
      {
        'date': '2026-06-06',
        'status': 'taken',
        'display_status': 'on_time',
        'medicine_name': meds,
        'taken_at': '2026-06-06T07:00:00',
        'note': null,
        'symptoms': <String>[],
        'is_missed_day': false,
      },
    ];
  }

  static Map<String, dynamic> getDummyTreatmentPlan() {
    return {
      'id': 0,
      'user_id': 0,
      'start_date': '2026-06-01',
      'end_date': '2026-11-27',
      'total_days': 180,
      'current_day': 7,
      'status': 'active',
      'reminder_enabled': 1,
      'treatment_phase': 'Fase Intensif',
    };
  }

  static List<Map<String, dynamic>> getDummyMedicines() {
    return [
      {
        'id': 0,
        'user_id': 0,
        'name': 'Rifampicin 300mg, Isoniazid 300mg, '
            'Pyrazinamide 500mg, Ethambutol 400mg',
        'dosage': '1 tablet each',
        'schedule': '07:00',
        'treatment_phase': 'Fase Intensif',
        'frequency': 'daily',
      },
    ];
  }

  /// Returns the dates in the current week that have on-time dummy entries.
  static List<String> getDummyWeekTakenDates() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final dummy = getDummyHistory();
    final takenDates = <String>[];
    for (final item in dummy) {
      final st = item['status'] as String;
      if (st == 'taken' || st == 'taken_late') {
        final date = item['date'] as String;
        try {
          final parts = date.split('-');
          final d = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          if (!d.isBefore(weekStart) && !d.isAfter(weekEnd)) {
            takenDates.add(date);
          }
        } catch (_) {}
      }
    }
    return takenDates;
  }

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

  Future<Map<String, dynamic>?> getMonitoringById(int id) async {
    final db = await database;

    final results = await db.query(
      'monitoring',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

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
      WHERE med.user_id = ? AND md.missed_date >= ?
      ORDER BY md.missed_date DESC
    ''', [userId, realDataStartDate]);
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

  Future<bool> hasUnresolvedMissedDoses(int userId) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT md.id
      FROM missed_dose md
      JOIN medicine med ON md.medicine_id = med.id
      WHERE med.user_id = ? AND md.resolved = 0
        AND md.missed_date >= ?
      LIMIT 1
    ''', [userId, realDataStartDate]);

    return results.isNotEmpty;
  }

  Future<void> resolveAllMissedDoses(int userId) async {
    final db = await database;

    await db.rawUpdate('''
      UPDATE missed_dose
      SET resolved = 1
      WHERE id IN (
        SELECT md.id
        FROM missed_dose md
        JOIN medicine med ON md.medicine_id = med.id
        WHERE med.user_id = ? AND md.resolved = 0
      )
    ''', [userId]);
  }

  Future<void> checkAndRecordMissedDoses(int userId) async {
    final medicines = await getMedicines(userId);
    if (medicines.isEmpty) return;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterday = now.subtract(const Duration(days: 1));

    // Find the earliest gap start: either treatment plan start or last monitoring date
    final plan = await getTreatmentPlan(userId);
    DateTime? gapStart;

    if (plan != null && plan['start_date'] != null) {
      gapStart = DateTime.tryParse(plan['start_date'] as String);
    }

    // Clamp to realDataStartDate — dummy data before this date must not
    // trigger missed-dose detection.
    final realStart = DateTime.tryParse(realDataStartDate);
    if (realStart != null && (gapStart == null || gapStart.isBefore(realStart))) {
      gapStart = realStart;
    }

    // Find the most recent monitoring date
    String? lastMonitoredDate;
    final takenDates = await getMonitoringDates(userId, 'taken');
    for (final d in takenDates) {
      final dateStr = d['date'] as String;
      if (lastMonitoredDate == null ||
          dateStr.compareTo(lastMonitoredDate) > 0) {
        lastMonitoredDate = dateStr;
      }
    }
    final lateDates = await getMonitoringDates(userId, 'taken_late');
    for (final d in lateDates) {
      final dateStr = d['date'] as String;
      if (lastMonitoredDate == null ||
          dateStr.compareTo(lastMonitoredDate) > 0) {
        lastMonitoredDate = dateStr;
      }
    }

    // Start from the day after last monitored date, or from plan start
    if (lastMonitoredDate != null) {
      final parts = lastMonitoredDate.split('-');
      final nextDay = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ).add(const Duration(days: 1));

      if (gapStart == null || nextDay.isAfter(gapStart)) {
        gapStart = nextDay;
      }
    }

    // Re-clamp after adjusting from last monitored date
    if (realStart != null && gapStart != null && gapStart.isBefore(realStart)) {
      gapStart = realStart;
    }

    if (gapStart == null) return;

    // Walk from gapStart to yesterday, check each day
    final scheduleStr = medicines.first['schedule'] as String? ?? '07:00';
    final parts = scheduleStr.split(':');
    final scheduleHour = int.tryParse(parts[0]) ?? 7;
    final scheduleMinute =
        int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    for (var d = gapStart;
        !d.isAfter(yesterday);
        d = d.add(const Duration(days: 1))) {
      // Skip today
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (dateStr == todayStr) continue;

      // Check if 24h+ have passed since this day's schedule
      final daySchedule =
          DateTime(d.year, d.month, d.day, scheduleHour, scheduleMinute);
      if (!now.isAfter(daySchedule.add(const Duration(hours: 24)))) continue;

      // Check if monitoring exists for this date
      bool hasMonitoring = false;
      for (final med in medicines) {
        final mon =
            await getTodayMonitoring(med['id'] as int, dateStr);
        if (mon != null && mon['status'] == 'taken' ||
            mon != null && mon['status'] == 'taken_late') {
          hasMonitoring = true;
          break;
        }
      }
      if (hasMonitoring) continue;

      // Record missed dose for each medicine
      for (final med in medicines) {
        final medicineId = med['id'] as int;
        final existing = await getMissedDoseByDate(medicineId, dateStr);
        if (existing == null) {
          await insertMissedDose({
            'medicine_id': medicineId,
            'missed_date': dateStr,
            'resolved': 0,
            'doctor_contacted': 0,
            'note': '',
          });
        }
      }
    }
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
        AND m.status IN ('taken', 'taken_late')
        AND m.date >= ?
        AND m.date <= ?
      ORDER BY m.date ASC
    ''', [userId, startDate, endDate]);

    return results.map((r) => r['date'] as String).toList();
  }

  // ─── ADHERENCE STATS ──────────────────────────────────

  /// Returns adherence statistics computed consistently with the
  /// Treatment History page. Dummy records (June 1-6) count as valid
  /// treatment days alongside real monitoring data.
  ///
  /// Returns: `{taken, missed, totalDays, complianceRate}`
  Future<Map<String, dynamic>> getAdherenceStats(int userId) async {
    final history = await getMonitoringHistory(userId);
    final plan = await getTreatmentPlan(userId);
    final medicines = await getMedicines(userId);

    final monitoredDates = <String>{};

    // Group monitoring records by date (one entry per day)
    final groupedByDate = <String, List<Map<String, dynamic>>>{};
    for (final item in history) {
      final date = item['date'] as String;
      monitoredDates.add(date);
      groupedByDate.putIfAbsent(date, () => []).add(item);
    }

    // Build list with one unique entry per date
    final entries = <Map<String, dynamic>>[];
    for (final entry in groupedByDate.entries) {
      final date = entry.key;
      final records = entry.value;

      String overallStatus = 'taken';
      for (final r in records) {
        final st = r['status'] as String? ?? '';
        if (st == 'taken_late') overallStatus = 'taken_late';
      }

      final displayStatus =
          overallStatus == 'taken_late' ? 'late' : 'on_time';

      entries.add({
        'date': date,
        'display_status': displayStatus,
      });
    }

    // Merge dummy data (only for dates without real monitoring records)
    if (useDummyData) {
      for (final item in getDummyHistory()) {
        if (!monitoredDates.contains(item['date'])) {
          entries.add({
            'date': item['date'],
            'display_status': item['display_status'],
          });
        }
      }
    }

    // Detect missed days: walk from plan start (clamped to realDataStartDate)
    // to yesterday; any date with no monitoring record is a missed day.
    // Skip when useDummyData is on — dummy already fills the gap visually.
    if (!useDummyData && plan != null && medicines.isNotEmpty) {
      final startStr = plan['start_date'] as String?;
      final startDate = DateTime.tryParse(startStr ?? '');
      if (startDate != null) {
        final realStart = DateTime.tryParse(realDataStartDate);
        final effectiveStart =
            realStart != null && startDate.isBefore(realStart)
                ? realStart
                : startDate;

        final now = DateTime.now();
        for (var d = effectiveStart;
            d.isBefore(now);
            d = d.add(const Duration(days: 1))) {
          final dateStr =
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

          if (monitoredDates.contains(dateStr)) continue;
          // Skip today — not yet missed
          final todayStr =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          if (dateStr == todayStr) continue;

          // Check 24h+ past schedule
          final scheduleStr =
              medicines.first['schedule'] as String? ?? '07:00';
          final parts = scheduleStr.split(':');
          final scheduleHour = int.tryParse(parts[0]) ?? 7;
          final scheduleMinute =
              int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
          final scheduledDate =
              DateTime(d.year, d.month, d.day, scheduleHour, scheduleMinute);

          if (now.isAfter(scheduledDate.add(const Duration(hours: 24)))) {
            entries.add({
              'date': dateStr,
              'display_status': 'missed',
            });
          }
        }
      }
    }

    // Count ALL entries (including dummy data)
    int taken = 0;
    int totalDays = 0;
    for (final item in entries) {
      totalDays++;
      final ds = item['display_status'] as String;
      if (ds == 'on_time' || ds == 'late') {
        taken++;
      }
    }

    final int missed = totalDays - taken;
    final double rate =
        totalDays == 0 ? 0.0 : (taken / totalDays * 100);

    return {
      'taken': taken,
      'missed': missed,
      'totalDays': totalDays,
      'complianceRate': rate,
    };
  }

  // ─── RESET TREATMENT DATA ──────────────────────────

  /// Completely resets all treatment progress and monitoring data
  /// while preserving user account, medicine, and treatment configuration.
  ///
  /// Deletes: monitoring, monitoring_symptom, missed_dose, user_badge
  /// Resets:  treatment_plan start_date to today, current_day to 1,
  ///          end_date recalculated, status to 'active'
  Future<void> resetTreatmentData(int userId) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1. Delete monitoring_symptom for all user's monitoring records
      await txn.rawDelete('''
        DELETE FROM monitoring_symptom
        WHERE monitoring_id IN (
          SELECT m.id FROM monitoring m
          JOIN medicine med ON m.medicine_id = med.id
          WHERE med.user_id = ?
        )
      ''', [userId]);

      // 2. Delete all monitoring records for user's medicines
      await txn.rawDelete('''
        DELETE FROM monitoring
        WHERE medicine_id IN (
          SELECT id FROM medicine WHERE user_id = ?
        )
      ''', [userId]);

      // 3. Delete all missed_dose records for user's medicines
      await txn.rawDelete('''
        DELETE FROM missed_dose
        WHERE medicine_id IN (
          SELECT id FROM medicine WHERE user_id = ?
        )
      ''', [userId]);

      // 4. Delete all user_badge records (earned badges)
      await txn.rawDelete('''
        DELETE FROM user_badge WHERE user_id = ?
      ''', [userId]);

      // 5. Reset treatment plan: set today as new start date
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Get the current plan to preserve total_days and other config
      final plans = await txn.query(
        'treatment_plan',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (plans.isNotEmpty) {
        final plan = plans.first;
        final totalDays = plan['total_days'] as int? ?? 180;

        // Calculate new end_date from today + total_days
        final endDate =
            now.add(Duration(days: totalDays - 1));
        final endDateStr =
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

        await txn.update(
          'treatment_plan',
          {
            'start_date': todayStr,
            'end_date': endDateStr,
            'current_day': 1,
            'status': 'active',
          },
          where: 'id = ?',
          whereArgs: [plan['id']],
        );
      }
    });
  }

  // ─── CLOSE DATABASE ─────

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
