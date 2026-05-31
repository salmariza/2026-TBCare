import 'package:flutter/material.dart';
import 'package:tbcare_app/presentation/screens/monitoring/monitoring.dart';

class MonitoringDoneScreen extends StatelessWidget {
  final List<Map<String, dynamic>> medicines;
  final Map<int, bool> symptoms;
  final List<Map<String, dynamic>> allSymptoms;
  final String note;
  final DateTime takenAt;
  final bool isLate;

  const MonitoringDoneScreen({
    super.key,
    required this.medicines,
    required this.symptoms,
    required this.allSymptoms,
    required this.note,
    required this.takenAt,
    required this.isLate,
  });

  String get medicineText {
    if (medicines.isEmpty) return '-';

    return medicines.map((medicine) => medicine['name'] as String).join(' - ');
  }

  List<String> get selectedSymptoms {
    List<String> result = [];

    for (final symptom in allSymptoms) {
      final id = symptom['id'];

      if (symptoms[id] == true) {
        result.add(symptom['name']);
      }
    }

    return result;
  }

  String formatTime() {
    return '${takenAt.hour.toString().padLeft(2, '0')}:${takenAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091413),

      bottomNavigationBar: _bottomNavbar(context),

      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF091413), Color(0xFF0D1F1C), Color(0xFF163028)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),

            child: Column(
              children: [
                // =========================
                // ICON SUCCESS
                // =========================
                Container(
                  width: 74,
                  height: 74,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: const Color(0x22D3FFEA),

                    border: Border.all(
                      color: const Color(0xFFD3FFEA),
                      width: 2,
                    ),

                    boxShadow: const [
                      BoxShadow(color: Color(0x55B0E4CC), blurRadius: 30),
                    ],
                  ),

                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFFD3FFEA),
                    size: 42,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Pemantauan Selesai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Disimpan pada ${formatTime()} WIB',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),

                const SizedBox(height: 32),

                // =========================
                // CONTENT CARD
                // =========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),

                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x44285A48), Color(0x44408A71)],
                    ),

                    border: Border.all(color: const Color(0x33B0E4CC)),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =========================
                      // MEDICINE
                      // =========================
                      const Text(
                        'OBAT YANG DIMINUM',
                        style: TextStyle(
                          color: Color(0xFFC0C9C2),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          const Icon(
                            Icons.medication_outlined,
                            color: Color(0xFFB0E4CC),
                            size: 20,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              medicineText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // =========================
                      // SYMPTOMS
                      // =========================
                      const Text(
                        'GEJALA DIRASAKAN',
                        style: TextStyle(
                          color: Color(0xFFC0C9C2),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,

                        children: selectedSymptoms.map((symptom) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0x26B0E4CC),

                              borderRadius: BorderRadius.circular(40),

                              border: Border.all(
                                color: const Color(0x55B0E4CC),
                              ),
                            ),

                            child: Text(
                              '🌡️ $symptom',
                              style: const TextStyle(
                                color: Color(0xFFB0E4CC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // =========================
                      // NOTE
                      // =========================
                      const Text(
                        'CATATAN HARIAN',
                        style: TextStyle(
                          color: Color(0xFFC0C9C2),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.only(left: 16),

                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFD3FFEA),
                              width: 2,
                            ),
                          ),
                        ),

                        child: Text(
                          '"$note"',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            height: 1.7,
                          ),
                        ),
                      ),

                      // =========================
                      // WARNING LATE
                      // =========================
                      if (isLate) ...[
                        const SizedBox(height: 28),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0x22FFB464),

                            borderRadius: BorderRadius.circular(14),

                            border: Border.all(color: const Color(0x55FFB464)),
                          ),

                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFFB464),
                                size: 18,
                              ),

                              SizedBox(width: 10),

                              Text(
                                'Terlambat',
                                style: TextStyle(
                                  color: Color(0xFFFFB464),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // =========================
                // BUTTON EDIT
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MonitoringPage(),
                        ),
                      );
                    },

                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2F8A6D)),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text(
                      'Edit Rekaman',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // BUTTON HOME
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C9B80),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavbar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF091413),

      currentIndex: 1,

      selectedItemColor: const Color(0xFFB0E4CC),
      unselectedItemColor: Colors.white38,

      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }

        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MonitoringPage()),
          );
        }

        if (index == 2) {
          Navigator.pushReplacementNamed(context, '/history');
        }

        if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_rounded),
          label: 'Pemantauan',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'Riwayat',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
