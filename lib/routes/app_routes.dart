import 'package:flutter/material.dart';
import 'package:tbcare_app/presentation/screens/splash/welcome_screen.dart';
import 'package:tbcare_app/presentation/screens/auth/login_screen.dart';
import 'package:tbcare_app/presentation/screens/auth/register_screen.dart';
import 'package:tbcare_app/presentation/screens/patient/patient_setup_screen.dart';
import 'package:tbcare_app/presentation/screens/monitoring/monitoring.dart';
import 'package:tbcare_app/presentation/screens/monitoring/warning_monitoring.dart';
import 'package:tbcare_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:tbcare_app/presentation/screens/history/riwayat_pengobatan.dart';
import 'package:tbcare_app/presentation/screens/notification/notification.dart';
import 'package:tbcare_app/presentation/screens/profile/profile_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String patientSetup = '/patient_setup';
  static const String dashboard = '/dashboard';
  static const String monitoring = '/monitoring';
  static const String history = '/history';
  static const String notification = '/notification';
  static const String warning = '/warning';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      patientSetup: (context) => const PatientSetupScreen(),
      dashboard: (context) => const DashboardScreen(),
      monitoring: (context) => const MonitoringPage(),
      history: (context) => const HistoryPage(),
      notification: (context) => const NotificationPage(),
      warning: (context) => const WarningPage(),
      profile: (context) => const ProfileScreen(),
    };
  }
}
