import 'package:tbcare_app/data/services/database_service.dart';
import 'package:tbcare_app/data/services/session_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Semua field harus diisi');
    }

    final db = await DatabaseService.instance.database;
    final existingUser = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email sudah terdaftar');
    }

    final id = await db.insert('user', {
      'name': name,
      'email': email,
      'password': password,
    });

    return {'id': id, 'name': name, 'email': email};
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    try {
      final db = await DatabaseService.instance.database;
      final result = await db.query(
        'user',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isEmpty) return null;

      final user = result.first;
      SessionService.instance.setUser(
        user['id'] as int,
        user['name'] as String,
        user['email'] as String,
      );

      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasTreatmentPlan(int userId) async {
    final plan = await DatabaseService.instance.getTreatmentPlan(userId);
    return plan != null;
  }
}
