import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Menunggu 2.5 detik sebelum berpindah halaman
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091413),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091413), Color(0xFF285A48)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ornamen Glow Atas
            Positioned(
              left: -75,
              top: -90,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: 300,
                  height: 327,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB0E4CC),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Ornamen Glow Bawah
            Positioned(
              left: 50,
              bottom: 0,
              child: Opacity(
                opacity: 0.10,
                child: Container(
                  width: 400,
                  height: 436,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB0E4CC),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Konten Tengah
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mascot Image
                Container(
                  height: 220,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB0E4CC).withOpacity(0.15),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/mascot.png',
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image isn't placed yet
                      return Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Color(0xFFB0E4CC),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'TB Care',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.90,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tetap Konsisten, Tetap Sehat',
                  style: TextStyle(
                    color: Color(0xCCB0E4CC),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
