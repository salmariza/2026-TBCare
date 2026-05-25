import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/database_service.dart';
import 'package:tbcare_app/data/services/session_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'Semua';

  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  int _totalDoses = 0;
  int _streak = 0;
  double _complianceRate = 0;
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
      final history = await db.getMonitoringHistory(userId);
      final streak = await db.calculateStreak(userId);

      int taken = 0;
      final enriched = <Map<String, dynamic>>[];
      for (final item in history) {
        final symptoms =
            await db.getSymptomsForMonitoring(item['id'] as int);
        final missed = item['status'] != 'taken';
        if (!missed) taken++;

        final symptomNames =
            symptoms.map((s) => s['name'] as String).toList();
        if (symptomNames.isEmpty) {
          symptomNames.add('Tidak Ada Gejala');
        }

        enriched.add({
          ...item,
          'symptoms': symptomNames,
          'missed': missed,
        });
      }

      final rate = history.isEmpty ? 0.0 : (taken / history.length * 100);

      if (mounted) {
        setState(() {
          _allHistory = enriched;
          _totalDoses = taken;
          _streak = streak;
          _complianceRate = rate;
          _isLoading = false;
          _applyFilter();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (selectedFilter == 'Semua') {
      _filteredHistory = List.from(_allHistory);
    } else if (selectedFilter == 'Sudah') {
      _filteredHistory =
          _allHistory.where((item) => item['missed'] == false).toList();
    } else if (selectedFilter == 'Terlewat') {
      _filteredHistory =
          _allHistory.where((item) => item['missed'] == true).toList();
    } else if (selectedFilter == 'Gejala') {
      _filteredHistory = _allHistory.where((item) {
        final symptoms = item['symptoms'] as List<String>;
        return !symptoms.contains('Tidak Ada Gejala');
      }).toList();
    }
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTimeAgo(String? takenAt, String dateStr) {
    if (takenAt == null) return dateStr;
    try {
      final dt = DateTime.parse(takenAt);
      final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      final diff = DateTime.now().difference(dt);
      if (diff.inDays == 0) return '$time · Today';
      if (diff.inDays == 1) return '$time · Kemarin';
      return '$time · ${diff.inDays} hari lalu';
    } catch (_) {
      return dateStr;
    }
  }

  String _getMonthLabel() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF091413),
        body: const Center(
            child: CircularProgressIndicator(color: Color(0xFFB0E4CC))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF091413),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.60, 0.03),
            end: Alignment(1.60, 0.97),
            colors: [
              Color(0xFF091413),
              Color(0xFF0D1F1C),
              Color(0xFF163028),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 24),
                _summaryCard(),
                const SizedBox(height: 20),
                _filterButtons(),
                const SizedBox(height: 24),
                _monthHeader(),
                const SizedBox(height: 16),
                _timeline(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TB CARE',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'Riwayat ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              TextSpan(
                text: 'Perawatan',
                style: TextStyle(
                  color: Color(0xFFB0E4CC),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Memantau proses pemulihanmu',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0),
                Colors.white.withOpacity(0.07),
                Colors.white.withOpacity(0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.16, -0.43),
          end: Alignment(0.84, 1.43),
          colors: [
            Color(0x47285A48),
            Color(0x1E408A71),
          ],
        ),
        border: Border.all(color: const Color(0x26B0E4CC)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem(
            icon: Icons.percent_rounded,
            value: '${_complianceRate.round()}%',
            label: 'Tingkat\nKepatuhan',
          ),
          _divider(),
          _summaryItem(
            icon: Icons.medication_rounded,
            value: '$_totalDoses',
            label: 'Dosis\nDiminum',
          ),
          _divider(),
          _summaryItem(
            icon: Icons.local_fire_department_rounded,
            value: '$_streak',
            label: 'Streak\nHarian',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        _smallIconBox(icon),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w300,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withOpacity(0.07),
    );
  }

  Widget _filterButtons() {
    final filters = ['Semua', 'Sudah', 'Terlewat', 'Gejala'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                  _applyFilter();
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0x59285A48)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: selected
                        ? const Color(0x3FB0E4CC)
                        : Colors.white.withOpacity(0.08),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFB0E4CC)
                        : Colors.white.withOpacity(0.40),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _monthHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x0FB0E4CC),
            border: Border.all(color: const Color(0x19B0E4CC)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getMonthLabel(),
            style: const TextStyle(
              color: Color(0xFFB0E4CC),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0),
                  Colors.white.withOpacity(0.07),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeline() {
    if (_filteredHistory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.history_rounded, color: Colors.white24, size: 48),
              SizedBox(height: 12),
              Text(
                'No monitoring history yet',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredHistory.map((item) {
        return _historyItem(item);
      }).toList(),
    );
  }

  Widget _historyItem(Map<String, dynamic> item) {
    final bool missed = item['missed'] as bool;
    final List<String> symptoms =
        (item['symptoms'] as List?)?.cast<String>() ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _timelineIcon(missed: missed),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0.04, -0.04),
                  end: const Alignment(0.96, 1.04),
                  colors: missed
                      ? const [
                          Color(0x2D641E1E),
                          Color(0x14501414),
                        ]
                      : const [
                          Color(0x2D285A48),
                          Color(0x14408A71),
                        ],
                ),
                border: Border.all(
                  color: missed
                      ? const Color(0x1EFF6E6E)
                      : const Color(0x23B0E4CC),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _historyHeader(item),
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'REKAM GEJALA',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: symptoms.map((symptom) {
                      return _symptomChip(
                        label: symptom,
                        missed: missed,
                      );
                    }).toList(),
                  ),
                  if (item['note'] != null &&
                      (item['note'] as String).isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _noteBox(item['note'] as String, missed: missed),
                  ],
                  if (missed) ...[
                    const SizedBox(height: 10),
                    _doctorReminder(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyHeader(Map<String, dynamic> item) {
    final bool missed = item['missed'] as bool;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(item['date'] as String),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTimeAgo(item['taken_at'] as String?, item['date'] as String),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        _statusBadge(
          text: missed ? 'Terlewat' : 'Sudah',
          missed: missed,
        ),
      ],
    );
  }

  Widget _statusBadge({
    required String text,
    required bool missed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: missed ? const Color(0x19FF6E6E) : const Color(0x1EB0E4CC),
        border: Border.all(
          color: missed ? const Color(0x33FF6E6E) : const Color(0x3FB0E4CC),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            missed ? Icons.close_rounded : Icons.check_rounded,
            size: 12,
            color: missed ? const Color(0xFFF87171) : const Color(0xFFB0E4CC),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: missed ? const Color(0xFFF87171) : const Color(0xFFB0E4CC),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _symptomChip({
    required String label,
    required bool missed,
  }) {
    final bool noSymptom = label == 'Tidak Ada Gejala';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: missed
            ? const Color(0x14FF6E6E)
            : noSymptom
                ? Colors.white.withOpacity(0.05)
                : const Color(0x38285A48),
        border: Border.all(
          color: missed
              ? const Color(0x26FF6E6E)
              : noSymptom
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0x33B0E4CC),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            noSymptom ? Icons.check_circle_outline : Icons.sick_rounded,
            size: 10,
            color: missed
                ? const Color(0xCCF87171)
                : noSymptom
                    ? Colors.white38
                    : const Color(0xFFB0E4CC),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: missed
                  ? const Color(0xCCF87171)
                  : noSymptom
                      ? Colors.white38
                      : const Color(0xFFB0E4CC),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteBox(String note, {required bool missed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: missed
            ? const Color(0x0AFF5050)
            : Colors.white.withOpacity(0.03),
        border: Border.all(
          color: missed
              ? const Color(0x14FF5050)
              : Colors.white.withOpacity(0.05),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        note,
        style: TextStyle(
          color: missed ? const Color(0x66FCA5A5) : Colors.white38,
          fontSize: 10,
          fontStyle: FontStyle.italic,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w300,
          height: 1.63,
        ),
      ),
    );
  }

  Widget _doctorReminder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x11FF9632),
        border: Border.all(color: const Color(0x1EFF9632)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Color(0x7FFDBA74),
          ),
          SizedBox(width: 8),
          Text(
            'Laporkan kepada dokter',
            style: TextStyle(
              color: Color(0x7FFDBA74),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineIcon({required bool missed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: missed
              ? const [
                  Color(0xFF3A1A1A),
                  Color(0xFF6B2C2C),
                ]
              : const [
                  Color(0xFF285A48),
                  Color(0xFF408A71),
                ],
        ),
        border: Border.all(
          width: 2,
          color: missed ? const Color(0x99FF6E6E) : const Color(0xFFB0E4CC),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: missed ? const Color(0x33FF5050) : const Color(0x59B0E4CC),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(
        missed ? Icons.close_rounded : Icons.check_rounded,
        color: missed ? const Color(0xFFFF6E6E) : const Color(0xFFB0E4CC),
        size: 20,
      ),
    );
  }

  Widget _smallIconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0x1EB0E4CC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: const Color(0xFFB0E4CC),
        size: 20,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xF20A1614),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Beranda', false, () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }),
            _buildNavItem(Icons.fact_check_rounded, 'Pemantauan', false, () {
              Navigator.pushReplacementNamed(context, '/monitoring');
            }),
            _buildNavItem(Icons.history_rounded, 'Riwayat', true, () {}),
            _buildNavItem(Icons.person_rounded, 'Profil', false, () {
              Navigator.pushReplacementNamed(context, '/profile');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: selected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: selected
            ? BoxDecoration(
                color: const Color(0x59285A48),
                border: Border.all(color: const Color(0x33B0E4CC)),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFFB0E4CC) : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFB0E4CC) : Colors.white38,
                fontSize: selected ? 12 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
