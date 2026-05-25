import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tbcare_app/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Sqflite tidak mendukung web karena memerlukan akses file lokal.
  // Desktop (Windows/Linux/macOS): inisialisasi FFI-based sqflite.
  // Mobile (Android/iOS): menggunakan native sqflite plugin secara otomatis.
  if (kIsWeb) {
    throw UnsupportedError(
      'TB Care tidak mendukung web. Gunakan perangkat mobile atau desktop.\n'
      'Jalankan: flutter run -d windows  (atau android/ios)',
    );
  }

  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TB Care',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a5555),
        ),
      ),
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.getRoutes(),
    );
  }
}
