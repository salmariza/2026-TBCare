import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF091413), Color(0xFF0D1F1C), Color(0xFF163028)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildGreetingText(),
                const SizedBox(height: 24),
                _buildProgressCard(),
                const SizedBox(height: 16),
                _buildMedicineReminderCard(),
                const SizedBox(height: 16),
                _buildTodayStatusCard(),
                const SizedBox(height: 16),
                _buildBadgesCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x4CB0E4CC), width: 2),
                    image: const DecorationImage(
                      image: NetworkImage("https://placehold.co/44x44"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF408A71),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF091413), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Pagi',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'Ridahas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.90),
                    fontSize: 14,
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
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_none, color: Colors.white, size: 20),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB0E4CC),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              height: 1.38,
            ),
            children: [
              TextSpan(text: 'Tetap konsisten\n', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'dengan pengobatanmu', style: TextStyle(color: Color(0xFFB0E4CC))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Perjalanan kesehatanmu berlanjut hari ini.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERKEMBANGAN PERAWATAN',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.60),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(text: 'Hari ke- ', style: TextStyle(color: Colors.white)),
                        TextSpan(text: '23', style: TextStyle(color: Color(0xFFB0E4CC))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'dari total 180 hari',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: 0.13,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB0E4CC)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '13%',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'selesai',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.50), fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.13,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB0E4CC)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFFB0E4CC), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tersisa 157 hari',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Color(0xFFB0E4CC), size: 12),
                    SizedBox(width: 6),
                    Text(
                      'Sesuai Jadwal',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineReminderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFB0E4CC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3FB0E4CC),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0x33285A48),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.medical_services_outlined, color: Color(0xFF285A48), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktunya untuk',
                        style: TextStyle(color: Color(0xFF285A48), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'minum obat',
                        style: TextStyle(color: Color(0xFF285A48), fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.more_vert, color: Color(0xFF285A48)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x1E285A48),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.access_time, color: Color(0xB2285A48), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Terjadwal: 07:00',
                    style: TextStyle(color: Color(0xB2285A48), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.medication, color: Color(0x99285A48), size: 16),
                SizedBox(width: 4),
                Text(
                  'Rifampicin ·\nIsoniazid',
                  style: TextStyle(color: Color(0x99285A48), fontSize: 12, height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF285A48), Color(0xFF1E4435)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66285A48),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tandai Sudah',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Hari Ini',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              Text(
                'Wed, 8 Jan',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.30), fontSize: 12),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x3F285A48),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x3FB0E4CC)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0x59285A48),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today, color: Color(0xFFB0E4CC)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hari Ini', style: TextStyle(color: Colors.white.withValues(alpha: 0.50), fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.check_circle, color: Color(0xFFB0E4CC), size: 16),
                        SizedBox(width: 6),
                        Text('Sudah', style: TextStyle(color: Color(0xFFB0E4CC), fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text('07:03', style: TextStyle(color: Colors.white.withValues(alpha: 0.30), fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Minggu ini', style: TextStyle(color: Colors.white.withValues(alpha: 0.40), fontSize: 12)),
              const Text('6/7 hari', style: TextStyle(color: Color(0xB2B0E4CC), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              bool isDone = index < 6;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFF408A71) : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.20), fontSize: 9),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Badge Terkumpul',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              Text(
                'Wed, 8 Jan',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.30), fontSize: 12),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadgeItem('1 Minggu Disiplin', 1),
              _buildBadgeItem('2 Minggu Disiplin', 2),
              _buildBadgeItem('3 Minggu Disiplin', 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String title, int weeks) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFFACC15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x66FBBF24),
                blurRadius: 20,
              ),
            ],
          ),
          child: Icon(Icons.star, color: Colors.white.withValues(alpha: 0.9), size: 28),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFA8A8A8),
              fontSize: 10,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xF20A1614),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Beranda', true),
            _buildNavItem(Icons.monitor_heart_outlined, 'Pemantauan', false),
            _buildNavItem(Icons.history, 'Riwayat', false),
            _buildNavItem(Icons.person_outline, 'Profil', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: isActive ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : const EdgeInsets.all(8),
          decoration: isActive
              ? BoxDecoration(
                  color: const Color(0x59285A48),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x33B0E4CC)),
                )
              : null,
          child: Row(
            children: [
              Icon(icon, color: isActive ? const Color(0xFFB0E4CC) : Colors.white.withValues(alpha: 0.30), size: 20),
              if (isActive) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFFB0E4CC), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ]
            ],
          ),
        ),
        if (!isActive) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.30), fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ]
      ],
    );
  }
}