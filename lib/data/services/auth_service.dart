import 'package:tbcare_app/data/services/database_service.dart';

class AuthService {
  static Future<void> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Semua field harus diisi');
    }

    try {
      final db = await DatabaseService.database;
      final existingUser = await db.query(
        'user',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUser.isNotEmpty) {
        throw Exception('Email sudah terdaftar');
      }

      await db.insert(
        'user',
        {
          'name': name,
          'email': email,
          'password': password,
        },
      );
    } catch (error) {
      throw Exception('Gagal mendaftar: ${error.toString()}');
    }
  }

  static Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    try {
      final db = await DatabaseService.database;
      final result = await db.query(
        'user',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

