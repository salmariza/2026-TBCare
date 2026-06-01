import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/database_service.dart';
import 'package:tbcare_app/data/services/session_service.dart';
import 'package:tbcare_app/presentation/screens/monitoring/monitoring_done_screen.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  bool hasTakenMedicine = false;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _symptoms = [];

  final Map<int, bool> _selectedSymptoms = {};

  final TextEditingController noteController = TextEditingController();

  int get selectedSymptomCount =>
      _selectedSymptoms.values.where((value) => value).length;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = SessionService.instance.currentUserId;

    if (userId == null) return;

    final db = DatabaseService.instance;

    final medicines = await db.getMedicines(userId);
    final symptoms = await db.getAllSymptoms();

    if (mounted) {
      setState(() {
        _medicines = medicines;
        _symptoms = symptoms;

        for (final symptom in symptoms) {
          _selectedSymptoms[symptom['id']] = false;
        }
      });
    }
  }

  bool _isLate() {
    final now = DateTime.now();

    final scheduledTime = DateTime(now.year, now.month, now.day, 7, 0);

    return now.isAfter(scheduledTime);
  }

  String get _medicineDisplayText {
    if (_medicines.isEmpty) {
      return 'Belum ada obat';
    }

    final names = _medicines
        .map((medicine) => medicine['name'] as String)
        .toList();

    return '${names.join(' · ')} · Terjadwal 07:00';
  }

  Future<void> _submitMonitoring() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final now = DateTime.now();

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MonitoringDoneScreen(
              medicines: _medicines,
              symptoms: _selectedSymptoms,
              allSymptoms: _symptoms,
              note: noteController.text,
              takenAt: now,
              isLate: _isLate(),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFF091413),

      bottomNavigationBar: _bottomNavigation(),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.17, 0.02),
            end: Alignment(1.17, 0.98),
            colors: [Color(0xFF091413), Color(0xFF0D1F1C), Color(0xFF163028)],
          ),
        ),

        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x66285A48), Colors.transparent],
                    ),
                  ),
                ),
              ),

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(now),

                    const SizedBox(height: 20),

                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildDailySection(),

                    const SizedBox(height: 24),

                    _buildSymptomsSection(),

                    const SizedBox(height: 24),

                    _buildNotesSection(),

                    const SizedBox(height: 24),

                    _buildSubmitButton(now),

                    const SizedBox(height: 14),

                    _buildPrivacyText(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime now) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PEMANTAUAN HARIAN',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),

              SizedBox(height: 6),

              Text(
                'Bagaimana\nkabarmu hari ini?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 74,
          padding: const EdgeInsets.symmetric(vertical: 12),

          decoration: BoxDecoration(
            color: const Color(0x19B0E4CC),

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: const Color(0x26B0E4CC)),
          ),

          child: Column(
            children: [
              Text(
                days[now.weekday - 1],
                style: const TextStyle(
                  color: Color(0xFFB0E4CC),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),

              Text(
                '${now.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                '${months[now.month - 1]} ${now.year}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          icon: Icons.medication_rounded,
          title: 'Ceklis Harian',
          subtitle: 'Kepatuhan minum obat',
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x4C285A48), Color(0x26408A71)],
            ),

            border: Border.all(color: const Color(0x2DB0E4CC)),
          ),

          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconContainer(Icons.medication_rounded),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apakah kamu sudah minum\nobat hari ini?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          _medicineDisplayText,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  setState(() {
                    hasTakenMedicine = true;
                  });
                },

                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),

                    gradient: const LinearGradient(
                      colors: [Color(0xFF285A48), Color(0xFF408A71)],
                    ),

                    border: Border.all(color: const Color(0x66B0E4CC)),

                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66285A48),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),

                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),

                      SizedBox(width: 8),

                      Text(
                        'Ya, Sudah',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: const Color(0x14B0E4CC),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,

                      decoration: const BoxDecoration(
                        color: Color(0xFFB0E4CC),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        'Tandai sudah diminum pada 07.03',
                        style: TextStyle(
                          color: Color(0xB2B0E4CC),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFFB0E4CC),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      children: [
        _sectionHeader(
          icon: Icons.health_and_safety_rounded,
          title: 'Ceklis Gejala',
          subtitle: 'Pilih semua yang sesuai hari ini',

          trailing: Text(
            '$selectedSymptomCount terpilih',
            style: const TextStyle(color: Color(0xFFB0E4CC), fontSize: 12),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),

          child: Column(
            children: [
              ..._symptoms.map((symptom) {
                return _symptomTile(
                  symptomId: symptom['id'],
                  title: symptom['name'],
                  subtitle: symptom['description'] ?? '',
                );
              }),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: const Color(0x11FFB464),

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: const Color(0x1EFFB464)),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFFED7AA),
                      size: 16,
                    ),

                    SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Jika gejala berlanjut, silakan hubungi dokter Anda.',
                        style: TextStyle(
                          color: Color(0x7FFED7AA),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _symptomTile({
    required int symptomId,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedSymptoms[symptomId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0x38285A48)
            : Colors.white.withOpacity(0.03),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: isSelected
              ? const Color(0x4CB0E4CC)
              : Colors.white.withOpacity(0.07),
        ),
      ),

      child: Row(
        children: [
          _iconContainer(Icons.sick_rounded),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: isSelected,

            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF408A71),

            onChanged: (value) {
              setState(() {
                _selectedSymptoms[symptomId] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      children: [
        _sectionHeader(
          icon: Icons.edit_note_rounded,
          title: 'Catatan Harian',
          subtitle: 'Opsional — Ceritakan apa yang kamu rasakan hari ini',
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),

          child: Column(
            children: [
              TextField(
                controller: noteController,
                maxLines: 6,
                maxLength: 500,

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  hintText: 'Tulis catatan harian...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),

                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),

                  counterStyle: const TextStyle(
                    color: Colors.white24,
                    fontSize: 11,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(DateTime now) {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitMonitoring,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          gradient: const LinearGradient(
            colors: [Color(0xFF285A48), Color(0xFF3A7A60)],
          ),

          boxShadow: const [
            BoxShadow(
              color: Color(0x7F285A48),
              blurRadius: 36,
              offset: Offset(0, 12),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),

                borderRadius: BorderRadius.circular(12),
              ),

              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan rekaman hari ini',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${now.day}/${now.month}/${now.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyText() {
    return const Center(
      child: Text(
        'Data Anda bersifat pribadi dan tersimpan dengan aman.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 10),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        _smallIcon(icon),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),

        if (trailing != null) trailing,
      ],
    );
  }

  Widget _smallIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,

      decoration: BoxDecoration(
        color: const Color(0x4C285A48),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: const Color(0x1EB0E4CC)),
      ),

      child: Icon(icon, color: const Color(0xFFB0E4CC), size: 16),
    );
  }

  Widget _iconContainer(IconData icon) {
    return Container(
      width: 42,
      height: 42,

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Icon(icon, color: const Color(0xFFB0E4CC)),
    );
  }

  Widget _bottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xF20A1614),

      currentIndex: 1,

      type: BottomNavigationBarType.fixed,

      selectedItemColor: const Color(0xFFB0E4CC),
      unselectedItemColor: Colors.white38,

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/dashboard');
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
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
