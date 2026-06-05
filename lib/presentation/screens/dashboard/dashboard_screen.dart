import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/database_service.dart';
import 'package:tbcare_app/data/services/session_service.dart';
import 'package:tbcare_app/widgets/custom_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _treatmentPlan;
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _userBadges = [];
  Map<String, dynamic>? _todayMonitoring;
  int _streak = 0;
  List<String> _weekTakenDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final userId = SessionService.instance.currentUserId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final db = DatabaseService.instance;
      final user = await db.getUser(userId);
      final plan = await db.getTreatmentPlan(userId);
      final medicines = await db.getMedicines(userId);
      final badges = await db.getUserBadges(userId);
      final streak = await db.calculateStreak(userId);
      final weekDates = await db.getWeekTakenDates(userId);

      Map<String, dynamic>? todayMon;
      final today = _todayString();
      for (final med in medicines) {
        final mon = await db.getTodayMonitoring(med['id'] as int, today);
        if (mon != null) {
          todayMon = mon;
          break;
        }
      }

      // Check for missed doses
      await _checkMissedDoses(userId, medicines);

      if (mounted) {
        setState(() {
          _user = user;
          _treatmentPlan = plan;
          _medicines = medicines;
          _userBadges = badges;
          _streak = streak;
          _weekTakenDates = weekDates;
          _todayMonitoring = todayMon;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkMissedDoses(
      int userId, List<Map<String, dynamic>> medicines) async {
    final db = DatabaseService.instance;

    final hadMissedBefore = await db.hasUnresolvedMissedDoses(userId);
    await db.checkAndRecordMissedDoses(userId);
    final hasMissedNow = await db.hasUnresolvedMissedDoses(userId);

    // Update treatment plan status if new missed doses appeared
    if (!hadMissedBefore && hasMissedNow && _treatmentPlan != null) {
      await db.updateTreatmentPlan(_treatmentPlan!['id'] as int, {
        'status': 'warning',
      });
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int get _currentDay {
    if (_treatmentPlan == null) return 0;
    final startDate = DateTime.tryParse(_treatmentPlan!['start_date'] as String);
    if (startDate == null) return 0;
    return DateTime.now().difference(startDate).inDays + 1;
  }

  int get _totalDays {
    if (_treatmentPlan == null) return 180;
    final startDate = DateTime.tryParse(_treatmentPlan!['start_date'] as String);
    final endDate = DateTime.tryParse(_treatmentPlan!['end_date'] as String);
    if (startDate == null || endDate == null) return 180;
    return endDate.difference(startDate).inDays + 1;
  }

  double get _progressValue {
    if (_totalDays <= 0) return 0;
    return (_currentDay / _totalDays).clamp(0.0, 1.0);
  }

  int get _progressPercent => (_progressValue * 100).round();

  int get _remainingDays => _totalDays - _currentDay;

  String get _planStatus {
    if (_treatmentPlan == null) return 'Belum Mulai';
    return _treatmentPlan!['status'] as String? ?? 'Aktif';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String get _medicineDisplayText {
    if (_medicines.isEmpty) return 'Belum ada obat';
    return _medicines.map((m) => m['name'] as String).join(' · ');
  }

  String get _medicineSchedule {
    if (_medicines.isEmpty) return '07:00';
    return _medicines.first['schedule'] as String? ?? '07:00';
  }

  String get _todayDateFormatted {
    final now = DateTime.now();
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${days[now.weekday]}, ${now.day} ${months[now.month - 1]}';
  }

  bool get _isTodayTaken =>
      _todayMonitoring != null && _todayMonitoring!['status'] == 'taken';

  String get _todayTakenTime {
    if (_todayMonitoring == null || _todayMonitoring!['taken_at'] == null) {
      return '';
    }
    try {
      final dt = DateTime.parse(_todayMonitoring!['taken_at'] as String);
      return '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF091413),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFB0E4CC))),
      );
    }

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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.length > 1) {
      return name.substring(0, 2).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildHeader() {
    final name = _user?['name'] as String? ?? 'Pengguna';
    final initials = _getInitials(name);
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
                    color: const Color(0xFF285A48),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x4CB0E4CC),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFFB0E4CC),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
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
                      border: Border.all(
                        color: const Color(0xFF091413),
                        width: 2,
                      ),
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
                  _greeting,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  _user?['name'] as String? ?? 'Pengguna',
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
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, '/notification');
          },
          child: Container(
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
                const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 20,
                ),
                if (_treatmentPlan != null && _treatmentPlan!['status'] == 'warning')
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB464),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
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
              TextSpan(
                text: 'Tetap konsisten\n',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'dengan pengobatanmu',
                style: TextStyle(color: Color(0xFFB0E4CC)),
              ),
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
    if (_treatmentPlan == null) {
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
        child: const Column(
          children: [
            Text(
              'Belum ada rencana perawatan',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Silakan lengkapi data perawatan terlebih dahulu',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      );
    }

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
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Hari ke- ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: '$_currentDay',
                          style: const TextStyle(color: Color(0xFFB0E4CC)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'dari total $_totalDays hari',
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
                        value: _progressValue,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFB0E4CC),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_progressPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'selesai',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.50),
                            fontSize: 9,
                          ),
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
              value: _progressValue,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFB0E4CC),
              ),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFB0E4CC),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tersisa $_remainingDays hari',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      _planStatus == 'warning'
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle,
                      color: _planStatus == 'warning'
                          ? const Color(0xFFFFB464)
                          : const Color(0xFFB0E4CC),
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _planStatus == 'warning' ? 'Perhatian' : 'Sesuai Jadwal',
                      style: TextStyle(
                        color: _planStatus == 'warning'
                            ? const Color(0xFFFFB464)
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFF285A48),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Waktunya untuk',
                        style: TextStyle(
                          color: Color(0xFF285A48),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _medicines.isEmpty ? 'minum obat' : 'minum obat',
                        style: const TextStyle(
                          color: Color(0xFF285A48),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
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
              children: [
                const Icon(Icons.access_time, color: Color(0xB2285A48), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Terjadwal: $_medicineSchedule',
                    style: const TextStyle(
                      color: Color(0xB2285A48),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.medication, color: Color(0x99285A48), size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _medicineDisplayText,
                    style: const TextStyle(
                      color: Color(0x99285A48),
                      fontSize: 12,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushNamed(context, '/monitoring');
            },
            child: Container(
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tandai Sudah',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _todayDateFormatted,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.30),
                  fontSize: 12,
                ),
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
                  child: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFB0E4CC),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari Ini',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _isTodayTaken
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: _isTodayTaken
                              ? const Color(0xFFB0E4CC)
                              : Colors.white38,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isTodayTaken ? 'Sudah' : 'Belum diminum',
                          style: TextStyle(
                            color: _isTodayTaken
                                ? const Color(0xFFB0E4CC)
                                : Colors.white38,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (_isTodayTaken && _todayTakenTime.isNotEmpty)
                      Text(
                        _todayTakenTime,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.30),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minggu ini',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 12,
                ),
              ),
              Text(
                '${_weekTakenDates.length}/7 hari',
                style: const TextStyle(
                  color: Color(0xB2B0E4CC),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final now = DateTime.now();
              final dayStart = now.subtract(Duration(days: now.weekday - 1));
              final date = dayStart.add(Duration(days: index));
              final dateStr =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final isDone = _weekTakenDates.contains(dateStr);
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFFFFB464) // Yellow
                        : Colors.white.withValues(alpha: 0.12),
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
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.20),
                        fontSize: 9,
                      ),
                    ),
                  ),
                )
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
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Streak: $_streak hari',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.30),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          if (_userBadges.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Belum ada badge. Tetap konsisten minum obat untuk mendapatkan badge!',
                style: TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _userBadges.map((badge) {
                return _buildBadgeItem(
                  badge['title'] as String,
                  badge['required_streak'] as int,
                );
              }).toList(),
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
            boxShadow: [BoxShadow(color: Color(0x66FBBF24), blurRadius: 20)],
          ),
          child: Icon(
            Icons.star,
            color: Colors.white.withValues(alpha: 0.9),
            size: 28,
          ),
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
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (isActive) return;
        switch (label) {
          case 'Beranda':
            break;
          case 'Pemantauan':
            Navigator.pushReplacementNamed(context, '/monitoring');
            break;
          case 'Riwayat':
            Navigator.pushReplacementNamed(context, '/history');
            break;
          case 'Profil':
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: isActive
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                : const EdgeInsets.all(8),
            decoration: isActive
                ? BoxDecoration(
                    color: const Color(0x59285A48),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x33B0E4CC)),
                  )
                : null,
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? const Color(0xFFB0E4CC)
                      : Colors.white.withValues(alpha: 0.30),
                  size: 20,
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFB0E4CC),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isActive) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.30),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
