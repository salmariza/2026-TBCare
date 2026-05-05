import 'package:flutter/material.dart';
import 'package:tbcare_app/routes/app_routes.dart';

void main() {
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
