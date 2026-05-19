import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/database_service.dart';
import 'package:tbcare_app/data/services/session_service.dart';

class WarningPage extends StatefulWidget {
  const WarningPage({super.key});

  @override
  State<WarningPage> createState() => _WarningPageState();
}

class _WarningPageState extends State<WarningPage> {
  List<Map<String, dynamic>> _missedDoses = [];
  List<Map<String, dynamic>> _userBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = SessionService.instance.currentUserId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final db = DatabaseService.instance;
      final missedDoses = await db.getMissedDoses(userId);
      final badges = await db.getUserBadges(userId);

      if (mounted) {
        setState(() {
          _missedDoses = missedDoses;
          _userBadges = badges;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatMissedDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${days[date.weekday]}, ${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161211),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A2015),
              Color(0xFF161211),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _warningIcon(),
                    const SizedBox(height: 32),
                    const Text(
                      'Perjalanan Berhenti\nSebentar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: 0.10,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sistem mendeteksi kamu terlewat dosis kemarin. Jangan panik. '
                      'Pengobatan TBC harus hati-hati. Silakan hubungi Dokter atau '
                      'Pusat Kesehatan Anda untuk instruksi selanjutnya. '
                      'Pengobatan kamu tidak di-reset otomatis.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFA8A8A8),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.75,
                        letterSpacing: -0.50,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: Color(0xFFFFE26E)),
                      )
                    else if (_missedDoses.isNotEmpty)
                      ..._missedDoses.map((dose) => _missedDoseCard(dose)),
                    const SizedBox(height: 24),
                    _contactDoctorButton(context),
                    const SizedBox(height: 16),
                    _primaryButton(
                      text: 'Mulai dari hari pertama?',
                      color: const Color(0xFFF97316),
                      opacity: 0.90,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan hubungi dokter untuk opsi ini.'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _primaryButton(
                      text: 'Lanjut pengobatan terakhir',
                      color: const Color(0x7FF97316),
                      opacity: 0.70,
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                    ),
                    const SizedBox(height: 32),
                    _badgeCard(),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 16,
                child: _closeButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushReplacementNamed(context, '/dashboard');
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: const Icon(
          Icons.close_rounded,
          color: Colors.white70,
          size: 24,
        ),
      ),
    );
  }

  Widget _warningIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF78350F),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.warning_amber_rounded,
        color: Color(0xFFFFE26E),
        size: 42,
      ),
    );
  }

  Widget _missedDoseCard(Map<String, dynamic> dose) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0x9627272A),
          border: Border.all(color: const Color(0xFF3F3F46)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Dosis Terlewat - ${_formatMissedDate(dose['missed_date'] as String)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFF7A00),
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.56,
                letterSpacing: -0.50,
              ),
            ),
            if (dose['medicine_name'] != null) ...[
              const SizedBox(height: 4),
              Text(
                dose['medicine_name'] as String,
                style: const TextStyle(
                  color: Color(0xFFFFB464),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _contactDoctorButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membuka kontak dokter...')),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0x4CCA8A04),
          border: Border.all(color: const Color(0xFFCA8A04)),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 15,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital_rounded,
              color: Color(0xFFFFE26E),
              size: 26,
            ),
            SizedBox(width: 16),
            Flexible(
              child: Text(
                'Hubungi Dokter Sekarang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE26E),
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.56,
                  letterSpacing: -0.50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required Color color,
    required double opacity,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(9999),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            width: 2,
            color: const Color(0xFFFF7A00),
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(opacity),
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            height: 1.56,
            letterSpacing: -0.50,
          ),
        ),
      ),
    );
  }

  Widget _badgeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        border: Border.all(color: const Color(0xFF27272A)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Badge Sebelumnya',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.43,
              letterSpacing: -0.50,
            ),
          ),
          const SizedBox(height: 16),
          if (_userBadges.isEmpty)
            const Text(
              'Belum ada badge',
              style: TextStyle(color: Color(0xFFA8A8A8), fontSize: 12),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _userBadges.map((badge) {
                return _BadgeItem(
                  icon: _badgeIcon(badge['required_streak'] as int),
                  label: badge['title'] as String,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  IconData _badgeIcon(int streak) {
    if (streak >= 30) return Icons.military_tech_rounded;
    if (streak >= 14) return Icons.workspace_premium_rounded;
    return Icons.emoji_events_rounded;
  }
}

class _BadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BadgeItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFACC15),
              borderRadius: BorderRadius.circular(9999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FBBF24),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF78350F),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFA8A8A8),
              fontSize: 10,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.4,
              letterSpacing: -0.50,
            ),
          ),
        ],
      ),
    );
  }
}
