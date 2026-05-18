import 'package:flutter/material.dart';

class DashboardEmptyView extends StatelessWidget {
  const DashboardEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan SingleChildScrollView agar tidak overflow di layar kecil
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0x4CB0E4CC), width: 2),
                        shape: BoxShape.circle,
                        // TODO: Ganti dengan image profile asli nantinya
                        image: const DecorationImage(
                          image: NetworkImage("https://ui-avatars.com/api/?name=Ridahas&background=random"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Pagi',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7), // Diperbaiki dari alpha: 0
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const Text(
                          'Ridahas',
                          style: TextStyle(
                            color: Colors.white, // Diperbaiki dari alpha: 0
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- TITLE ---
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 1.38,
                ),
                children: [
                  TextSpan(text: 'Ayo pantau pengobatanmu\n', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'bersama TB Care', style: TextStyle(color: Color(0xFFB0E4CC))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan data anda',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 32),

            // --- EMPTY STATE CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF285A48), Color(0xFF408A71)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x8C285A48),
                    blurRadius: 40,
                    offset: Offset(0, 12),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Kamu belum memasukkan data pengobatan.\nYuk, lengkapi datamu untuk memulai perjalanan sehatmu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Mascot Image Area
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      // TODO: Masukkan gambar maskot Tobi ke folder assets dan daftarkan di pubspec.yaml
                      // image: DecorationImage(image: AssetImage('assets/images/tobi_mascot.png')),
                    ),
                    child: const Center(
                      child: Icon(Icons.health_and_safety, size: 100, color: Color(0xFFB0E4CC)), // Placeholder smentara
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Ayo pantau dengan Tobi!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB0E4CC),
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Tambahkan aksi navigasi ke form pengobatan di sini
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF408A71),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0x66408A71),
                      ),
                      child: const Text(
                        'Masukkan Data Pengobatan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}