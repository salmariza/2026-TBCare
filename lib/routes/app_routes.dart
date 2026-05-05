import 'package:flutter/material.dart';
import 'package:tbcare_app/presentation/screens/splash/welcome_screen.dart';
import 'package:tbcare_app/presentation/screens/auth/login_screen.dart';
import 'package:tbcare_app/presentation/screens/auth/register_screen.dart';
import 'package:tbcare_app/presentation/screens/patient/patient_setup_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String patientSetup = '/patient_setup';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      patientSetup: (context) => const PatientSetupScreen(),
    };
  }
}
