import 'dart:ui';
import 'package:flutter/material.dart';

import '../patient/patient_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // =========================
  // CONTROLLER
  // =========================

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  // =========================
  // LOGIN FUNCTION
  // =========================

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // VALIDASI
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password wajib diisi")),
      );
      return;
    }

    // PINDAH KE PATIENT SETUP
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PatientSetupScreen()),
    );
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091413),

      body: Stack(
        children: [
          // =========================
          // BACKGROUND GLOW
          // =========================
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 300,
              height: 300,

              decoration: const BoxDecoration(
                shape: BoxShape.circle,

                gradient: RadialGradient(
                  colors: [Color(0x33285A48), Colors.transparent],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            right: -120,
            child: Container(
              width: 350,
              height: 350,

              decoration: const BoxDecoration(
                shape: BoxShape.circle,

                gradient: RadialGradient(
                  colors: [Color(0x22B0E4CC), Colors.transparent],
                ),
              ),
            ),
          ),

          // =========================
          // CONTENT
          // =========================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 30),

                  // =========================
                  // LOGO
                  // =========================
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 82,
                          height: 82,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),

                            gradient: const LinearGradient(
                              colors: [Color(0xFF285A48), Color(0xFF1E4435)],
                            ),

                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66285A48),
                                blurRadius: 25,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFB0E4CC),
                            size: 38,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "TB Care",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Tetap Konsisten,\nTetap Sehat",
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // =========================
                  // TITLE
                  // =========================
                  const Text(
                    "Masuk",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Masuk untuk melanjutkan monitoring pengobatan",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // EMAIL
                  // =========================
                  buildInputField(
                    controller: emailController,
                    hint: "Email",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 18),

                  // =========================
                  // PASSWORD
                  // =========================
                  buildInputField(
                    controller: passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    obscure: obscurePassword,

                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },

                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,

                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,

                    child: Text(
                      "Lupa Password?",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // =========================
                  // LOGIN BUTTON
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      onPressed: login,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF285A48),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),

                        elevation: 10,
                        shadowColor: const Color(0x66285A48),
                      ),

                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // GOOGLE BUTTON
                  // =========================
                  glassContainer(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),

                      onTap: () {},

                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Container(
                              width: 22,
                              height: 22,

                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),

                              child: const Center(
                                child: Text(
                                  "G",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            const Text(
                              "Masuk dengan Google",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // REGISTER
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        "Belum punya akun?",
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),

                      const SizedBox(width: 6),

                      const Text(
                        "Daftar",
                        style: TextStyle(
                          color: Color(0xFFB0E4CC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // COMPONENTS
  // =========================

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return glassContainer(
      child: TextField(
        controller: controller,
        obscureText: obscure,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),

          prefixIcon: Icon(icon, color: Colors.white70),

          suffixIcon: suffix,

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),

            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),

          child: child,
        ),
      ),
    );
  }
}
