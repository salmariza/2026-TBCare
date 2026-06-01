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
      final plan = await db.getTreatmentPlan(userId);
      final medicines = await db.getMedicines(userId);

      // Collect all dates that have monitoring records
      final monitoredDates = <String>{};
      final enriched = <Map<String, dynamic>>[];

      for (final item in history) {
        final status = item['status'] as String? ?? '';
        monitoredDates.add(item['date'] as String);

        // Determine display status
        String displayStatus;
        if (status == 'taken') {
          displayStatus = 'on_time';
        } else if (status == 'taken_late') {
          displayStatus = 'late';
        } else {
          displayStatus = 'missed';
        }

        // Load symptoms for this entry
        final symptoms =
            await db.getSymptomsForMonitoring(item['id'] as int);
        final symptomNames =
            symptoms.map((s) => s['name'] as String).toList();

        enriched.add({
          ...item,
          'symptoms': symptomNames,
          'display_status': displayStatus,
          'is_missed_day': false,
        });
      }

      // Find missed days (days with NO monitoring record)
      if (plan != null && medicines.isNotEmpty) {
        final startStr = plan['start_date'] as String;
        final startDate = DateTime.tryParse(startStr);
        if (startDate != null) {
          final now = DateTime.now();

          // Walk from start_date to yesterday
          for (var d = startDate;
              d.isBefore(now);
              d = d.add(const Duration(days: 1))) {
            final dateStr =
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

            // Skip if monitoring already exists for this date
            if (monitoredDates.contains(dateStr)) continue;
            // Skip today (not yet missed)
            if (dateStr ==
                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}') {
              continue;
            }

            // Check if 24h+ have passed since the schedule
            final scheduleStr =
                medicines.first['schedule'] as String? ?? '07:00';
            final parts = scheduleStr.split(':');
            final scheduleHour = int.tryParse(parts[0]) ?? 7;
            final scheduleMinute =
                int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
            final scheduledDate = DateTime(
                d.year, d.month, d.day, scheduleHour, scheduleMinute);

            if (now.isAfter(scheduledDate.add(const Duration(hours: 24)))) {
              enriched.add({
                'date': dateStr,
                'status': 'missed',
                'display_status': 'missed',
                'medicine_name':
                    medicines.map((m) => m['name']).join(', '),
                'taken_at': null,
                'note': null,
                'symptoms': <String>[],
                'is_missed_day': true,
              });
            }
          }
        }
      }

      // Sort by date descending
      enriched.sort((a, b) {
        final aDate = a['date'] as String;
        final bDate = b['date'] as String;
        return bDate.compareTo(aDate);
      });

      // Count taken doses (on_time + late both count)
      int taken = 0;
      for (final item in enriched) {
        if (item['display_status'] == 'on_time' ||
            item['display_status'] == 'late') {
          taken++;
        }
      }

      final totalDays = enriched.length;
      final rate = totalDays == 0 ? 0.0 : (taken / totalDays * 100);

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
      _filteredHistory = _allHistory.where((item) {
        final status = item['display_status'] as String;
        return status == 'on_time' || status == 'late';
      }).toList();
    } else if (selectedFilter == 'Terlewat') {
      _filteredHistory = _allHistory
          .where((item) => item['display_status'] == 'missed')
          .toList();
    } else if (selectedFilter == 'Gejala') {
      _filteredHistory = _allHistory.where((item) {
        final symptoms = item['symptoms'] as List;
        return symptoms.isNotEmpty;
      }).toList();
    }
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      const days = [
        'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
      ];
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
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.07),
                Colors.white.withValues(alpha: 0),
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
      color: Colors.white.withValues(alpha: 0.07),
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
                      : Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: selected
                        ? const Color(0x3FB0E4CC)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFB0E4CC)
                        : Colors.white.withValues(alpha: 0.40),
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
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.07),
                  Colors.white.withValues(alpha: 0),
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

  // ─── COLOR HELPERS ─────────────────────────────────────

  List<Color> _cardGradient(String status) {
    switch (status) {
      case 'late':
        return [const Color(0x2D7A5A20), const Color(0x14998040)];
      case 'missed':
        return [const Color(0x2D641E1E), const Color(0x14501414)];
      default: // on_time
        return [const Color(0x2D285A48), const Color(0x14408A71)];
    }
  }

  Color _cardBorderColor(String status) {
    switch (status) {
      case 'late':
        return const Color(0x23FFB464);
      case 'missed':
        return const Color(0x1EFF6E6E);
      default:
        return const Color(0x23B0E4CC);
    }
  }

  List<Color> _iconGradient(String status) {
    switch (status) {
      case 'late':
        return [const Color(0xFF7A5A20), const Color(0xFFB09040)];
      case 'missed':
        return [const Color(0xFF3A1A1A), const Color(0xFF6B2C2C)];
      default:
        return [const Color(0xFF285A48), const Color(0xFF408A71)];
    }
  }

  Color _iconBorderColor(String status) {
    switch (status) {
      case 'late':
        return const Color(0xFFFFB464);
      case 'missed':
        return const Color(0x99FF6E6E);
      default:
        return const Color(0xFFB0E4CC);
    }
  }

  Color _iconGlowColor(String status) {
    switch (status) {
      case 'late':
        return const Color(0x33FFB464);
      case 'missed':
        return const Color(0x33FF5050);
      default:
        return const Color(0x59B0E4CC);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'late':
        return Icons.access_time_rounded;
      case 'missed':
        return Icons.close_rounded;
      default:
        return Icons.check_rounded;
    }
  }

  Color _statusIconColor(String status) {
    switch (status) {
      case 'late':
        return const Color(0xFFFFB464);
      case 'missed':
        return const Color(0xFFFF6E6E);
      default:
        return const Color(0xFFB0E4CC);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'late':
        return 'Terlambat';
      case 'missed':
        return 'Terlewat';
      default:
        return 'Tepat Waktu';
    }
  }

  Color _statusBadgeColor(String status) {
    switch (status) {
      case 'late':
        return const Color(0xFFFFB464);
      case 'missed':
        return const Color(0xFFF87171);
      default:
        return const Color(0xFFB0E4CC);
    }
  }

  Color _statusBadgeBg(String status) {
    switch (status) {
      case 'late':
        return const Color(0x19FFB464);
      case 'missed':
        return const Color(0x19FF6E6E);
      default:
        return const Color(0x1EB0E4CC);
    }
  }

  Color _statusBadgeBorder(String status) {
    switch (status) {
      case 'late':
        return const Color(0x33FFB464);
      case 'missed':
        return const Color(0x33FF6E6E);
      default:
        return const Color(0x3FB0E4CC);
    }
  }

  // ─── HISTORY ITEM ───────────────────────────────────────

  Widget _historyItem(Map<String, dynamic> item) {
    final status = item['display_status'] as String;
    final isMissedDay = item['is_missed_day'] == true;
    final List<String> symptoms =
        (item['symptoms'] as List?)?.cast<String>() ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _timelineIcon(status: status),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0.04, -0.04),
                  end: const Alignment(0.96, 1.04),
                  colors: _cardGradient(status),
                ),
                border: Border.all(color: _cardBorderColor(status)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _historyHeader(item, status: status),
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.05),
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
                  if (symptoms.isEmpty)
                    const Text(
                      'Tidak ada gejala tercatat',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: symptoms.map((symptom) {
                        return _symptomChip(
                          label: symptom,
                          status: status,
                        );
                      }).toList(),
                    ),
                  if (item['note'] != null &&
                      (item['note'] as String).isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _noteBox(item['note'] as String, status: status),
                  ],
                  if (isMissedDay) ...[
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

  Widget _historyHeader(Map<String, dynamic> item, {required String status}) {
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
                _formatTimeAgo(
                    item['taken_at'] as String?, item['date'] as String),
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
          text: _statusLabel(status),
          status: status,
        ),
      ],
    );
  }

  Widget _statusBadge({
    required String text,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _statusBadgeBg(status),
        border: Border.all(color: _statusBadgeBorder(status)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _statusIcon(status),
            size: 12,
            color: _statusBadgeColor(status),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: _statusBadgeColor(status),
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
    required String status,
  }) {
    final bool noSymptom = label == 'Tidak Ada Gejala';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'missed'
            ? const Color(0x14FF6E6E)
            : status == 'late'
                ? const Color(0x14FFB464)
                : noSymptom
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0x38285A48),
        border: Border.all(
          color: status == 'missed'
              ? const Color(0x26FF6E6E)
              : status == 'late'
                  ? const Color(0x26FFB464)
                  : noSymptom
                      ? Colors.white.withValues(alpha: 0.08)
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
            color: status == 'missed'
                ? const Color(0xCCF87171)
                : status == 'late'
                    ? const Color(0xCCFFB464)
                    : noSymptom
                        ? Colors.white38
                        : const Color(0xFFB0E4CC),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: status == 'missed'
                  ? const Color(0xCCF87171)
                  : status == 'late'
                      ? const Color(0xCCFFB464)
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

  Widget _noteBox(String note, {required String status}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: status == 'missed'
            ? const Color(0x0AFF5050)
            : status == 'late'
                ? const Color(0x0AFFB464)
                : Colors.white.withValues(alpha: 0.03),
        border: Border.all(
          color: status == 'missed'
              ? const Color(0x14FF5050)
              : status == 'late'
                  ? const Color(0x14FFB464)
                  : Colors.white.withValues(alpha: 0.05),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        note,
        style: TextStyle(
          color: status == 'missed'
              ? const Color(0x66FCA5A5)
              : status == 'late'
                  ? const Color(0x66FFB464)
                  : Colors.white38,
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

  Widget _timelineIcon({required String status}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _iconGradient(status)),
        border: Border.all(width: 2, color: _iconBorderColor(status)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: _iconGlowColor(status), blurRadius: 12),
        ],
      ),
      child: Icon(
        _statusIcon(status),
        color: _statusIconColor(status),
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
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
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
