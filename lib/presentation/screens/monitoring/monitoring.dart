import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/database_service.dart';
import 'package:tbcare_app/data/services/session_service.dart';
import 'package:tbcare_app/presentation/screens/monitoring/monitoring_done_screen.dart';
import 'package:tbcare_app/presentation/screens/monitoring/monitoring_edit_screen.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Schedule-based state
  bool _canSubmit = false;
  DateTime? _scheduleDateTime;
  Timer? _scheduleTimer;

  // Existing monitoring state
  bool _hasExistingMonitoring = false;
  Map<String, dynamic>? _existingMonitoring;
  List<int> _existingMonitoringIds = [];
  List<Map<String, dynamic>> _existingSymptoms = [];

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

    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final db = DatabaseService.instance;
    final medicines = await db.getMedicines(userId);
    final symptoms = await db.getAllSymptoms();

    // Initialize symptom selection
    for (final symptom in symptoms) {
      _selectedSymptoms[symptom['id']] = false;
    }

    // Check if today's monitoring already exists
    final today = _todayString();
    bool alreadyTaken = false;
    final List<int> existingIds = [];
    Map<String, dynamic>? firstMonitoring;
    List<Map<String, dynamic>> loadedSymptoms = [];

    for (final medicine in medicines) {
      final existing = await db.getTodayMonitoring(medicine['id'] as int, today);
      if (existing != null) {
        alreadyTaken = true;
        existingIds.add(existing['id'] as int);
        firstMonitoring ??= existing;

        // Load note from first monitoring
        if (firstMonitoring['note'] != null &&
            (firstMonitoring['note'] as String).isNotEmpty &&
            noteController.text.isEmpty) {
          noteController.text = firstMonitoring['note'] as String;
        }

        // Load selected symptoms — accumulate across all medicines
        final monitoringSymptoms =
            await db.getSymptomsForMonitoring(existing['id'] as int);
        final seenIds = loadedSymptoms.map((s) => s['id']).toSet();
        for (final ms in monitoringSymptoms) {
          _selectedSymptoms[ms['id']] = true;
          if (!seenIds.contains(ms['id'])) {
            loadedSymptoms.add(ms);
            seenIds.add(ms['id']);
          }
        }
      }
    }

    // Determine schedule
    _scheduleDateTime = _parseSchedule(medicines);
    _canSubmit = _scheduleDateTime != null &&
        !DateTime.now().isBefore(_scheduleDateTime!);

    // Start timer if not yet at schedule time and no existing monitoring
    if (!alreadyTaken && _scheduleDateTime != null && !_canSubmit) {
      _startScheduleTimer();
    }

    if (mounted) {
      setState(() {
        _medicines = medicines;
        _symptoms = symptoms;
        _hasExistingMonitoring = alreadyTaken;
        _existingMonitoring = firstMonitoring;
        _existingMonitoringIds = existingIds;
        _existingSymptoms = loadedSymptoms;
        _isLoading = false;
      });
    }
  }

  DateTime? _parseSchedule(List<Map<String, dynamic>> medicines) {
    if (medicines.isEmpty) return null;

    final scheduleStr = medicines.first['schedule'] as String? ?? '07:00';
    final parts = scheduleStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 7;
    final minute =
        int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void _startScheduleTimer() {
    _scheduleTimer?.cancel();

    if (_scheduleDateTime == null) return;

    final now = DateTime.now();
    final diff = _scheduleDateTime!.difference(now);

    if (diff.isNegative) {
      // Already past schedule — enable immediately
      if (mounted) {
        setState(() => _canSubmit = true);
      }
      return;
    }

    // Set timer to fire at exact schedule time
    _scheduleTimer = Timer(diff, () {
      if (mounted) {
        setState(() => _canSubmit = true);
      }
    });
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get _isLate {
    if (_scheduleDateTime == null) return false;
    return DateTime.now().isAfter(_scheduleDateTime!);
  }

  String get _scheduleDisplayText {
    if (_scheduleDateTime == null) return '07:00';
    return '${_scheduleDateTime!.hour.toString().padLeft(2, '0')}:${_scheduleDateTime!.minute.toString().padLeft(2, '0')}';
  }

  String get _medicineDisplayText {
    if (_medicines.isEmpty) return 'Belum ada obat';

    final names =
        _medicines.map((medicine) => medicine['name'] as String).toList();
    return '${names.join(' · ')} · Terjadwal $_scheduleDisplayText';
  }

  String _formatTakenAtFromDb(String? takenAtStr) {
    if (takenAtStr == null) return '';
    try {
      final dt = DateTime.parse(takenAtStr);
      return '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  // ─── SUBMIT ───────────────────────────────────────────────

  Future<void> _submitMonitoring() async {
    if (_isSubmitting) return;
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final db = DatabaseService.instance;
      final now = DateTime.now();
      final today = _todayString();
      final takenAtStr = now.toIso8601String();
      final status = _isLate ? 'taken_late' : 'taken';
      final userId = SessionService.instance.currentUserId;
      final List<int> monitoringIds = [];

      for (final medicine in _medicines) {
        final medicineId = medicine['id'] as int;

        // Check if monitoring already exists for today (safety check)
        final existing = await db.getTodayMonitoring(medicineId, today);

        int monitoringId;
        if (existing != null) {
          await db.updateMonitoring(existing['id'] as int, {
            'status': status,
            'taken_at': takenAtStr,
            'note': noteController.text,
          });
          monitoringId = existing['id'] as int;
          await db.deleteSymptomsForMonitoring(monitoringId);
        } else {
          monitoringId = await db.insertMonitoring({
            'medicine_id': medicineId,
            'status': status,
            'date': today,
            'taken_at': takenAtStr,
            'note': noteController.text,
          });
        }
        monitoringIds.add(monitoringId);

        // Insert symptom links
        for (final entry in _selectedSymptoms.entries) {
          if (entry.value) {
            await db.insertMonitoringSymptom(monitoringId, entry.key);
          }
        }
      }

      // Check and award badges
      if (userId != null) {
        await db.checkAndAwardBadges(userId);
      }

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
              isLate: _isLate,
              monitoringIds: monitoringIds,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    noteController.dispose();
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF091413),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFB0E4CC)),
        ),
      );
    }

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
                    _divider(),
                    const SizedBox(height: 24),
                    if (_hasExistingMonitoring)
                      _buildSummaryMode()
                    else
                      _buildFormMode(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────

  Widget _buildHeader(DateTime now) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _hasExistingMonitoring
                    ? 'PEMANTAUAN HARI INI'
                    : 'PEMANTAUAN HARIAN',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _hasExistingMonitoring
                    ? 'Obat sudah\ndiminum hari ini'
                    : 'Bagaimana\nkabarmu hari ini?',
                style: const TextStyle(
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

  Widget _divider() {
    return Container(
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
    );
  }

  // ─── FORM MODE ────────────────────────────────────────────

  Widget _buildFormMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailyCheckForm(),
        const SizedBox(height: 24),
        _buildSymptomsSection(),
        const SizedBox(height: 24),
        _buildNotesSection(),
        const SizedBox(height: 14),
        _buildPrivacyText(),
      ],
    );
  }

  Widget _buildDailyCheckForm() {
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
              // "Ya, Sudah Minum" button — disabled before schedule
              GestureDetector(
                onTap: _canSubmit ? _submitMonitoring : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: _canSubmit
                        ? const LinearGradient(
                            colors: [Color(0xFF285A48), Color(0xFF408A71)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF1E2E2A), Color(0xFF253530)],
                          ),
                    border: Border.all(
                      color: _canSubmit
                          ? const Color(0x66B0E4CC)
                          : const Color(0x33FFFFFF),
                    ),
                    boxShadow: _canSubmit
                        ? const [
                            BoxShadow(
                              color: Color(0x66285A48),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _canSubmit
                            ? Icons.check_circle
                            : Icons.lock_outline,
                        color: _canSubmit
                            ? Colors.white
                            : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ya, Sudah Minum',
                        style: TextStyle(
                          color: _canSubmit ? Colors.white : Colors.white38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Schedule info bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _canSubmit
                      ? const Color(0x14B0E4CC)
                      : const Color(0x14FFB464),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _canSubmit
                            ? const Color(0xFFB0E4CC)
                            : const Color(0xFFFFB464),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _canSubmit
                            ? 'Siap diminum — tekan tombol di atas'
                            : 'Obat dapat diminum mulai pukul $_scheduleDisplayText',
                        style: TextStyle(
                          color: _canSubmit
                              ? const Color(0xB2B0E4CC)
                              : const Color(0xB2FFB464),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      _canSubmit
                          ? Icons.check_rounded
                          : Icons.access_time_rounded,
                      color: _canSubmit
                          ? const Color(0xFFB0E4CC)
                          : const Color(0xFFFFB464),
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

  // ─── SUMMARY MODE (existing monitoring) ───────────────────

  Widget _buildSummaryMode() {
    final isLate = _existingMonitoring != null &&
        _existingMonitoring!['status'] == 'taken_late';
    final takenAt = _existingMonitoring?['taken_at'] as String?;
    final note = _existingMonitoring?['note'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          icon: Icons.medication_rounded,
          title: 'Ceklis Harian',
          subtitle: 'Kepatuhan minum obat',
        ),
        const SizedBox(height: 12),
        // Status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLate
                  ? [const Color(0x4C7A5A20), const Color(0x26998040)]
                  : [const Color(0x4C285A48), const Color(0x26408A71)],
            ),
            border: Border.all(
              color: isLate
                  ? const Color(0x2DFFB464)
                  : const Color(0x2DB0E4CC),
            ),
          ),
          child: Column(
            children: [
              // Medicine name + status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconContainer(Icons.medication_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: isLate
                                  ? const Color(0xFFFFB464)
                                  : const Color(0xFFB0E4CC),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Obat sudah diminum',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
              const SizedBox(height: 14),
              // Time info + late badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isLate
                      ? const Color(0x22FFB464)
                      : const Color(0x14B0E4CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLate
                          ? Icons.warning_amber_rounded
                          : Icons.access_time_rounded,
                      color: isLate
                          ? const Color(0xFFFFB464)
                          : const Color(0xFFB0E4CC),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Diminum pukul ${_formatTakenAtFromDb(takenAt)}',
                        style: TextStyle(
                          color: isLate
                              ? const Color(0xB2FFB464)
                              : const Color(0xB2B0E4CC),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isLate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33FFB464),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0x55FFB464),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFFB464),
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Terlambat',
                              style: TextStyle(
                                color: Color(0xFFFFB464),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Symptoms summary
        _sectionHeader(
          icon: Icons.health_and_safety_rounded,
          title: 'Ceklis Gejala',
          subtitle: 'Gejala yang dirasakan hari ini',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: _existingSymptoms.isEmpty
              ? const Text(
                  'Tidak ada gejala yang dicatat',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _existingSymptoms.map((symptom) {
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
                        symptom['name'] as String? ?? '',
                        style: const TextStyle(
                          color: Color(0xFFB0E4CC),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 24),
        // Notes summary
        _sectionHeader(
          icon: Icons.edit_note_rounded,
          title: 'Catatan Harian',
          subtitle: 'Catatan yang ditulis hari ini',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: note.isEmpty || note.trim().isEmpty
              ? const Text(
                  'Tidak ada catatan',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                )
              : Container(
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
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      height: 1.7,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 28),
        // Edit button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_existingMonitoringIds.isNotEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MonitoringEditScreen(
                      monitoringId: _existingMonitoringIds.first,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A7A60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Edit Monitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildPrivacyText(),
      ],
    );
  }

  // ─── FORM SECTIONS ────────────────────────────────────────

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
            activeThumbColor: Colors.white,
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

  Widget _buildPrivacyText() {
    return const Center(
      child: Text(
        'Data Anda bersifat pribadi dan tersimpan dengan aman.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 10),
      ),
    );
  }

  // ─── SHARED HELPERS ───────────────────────────────────────

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
        ?trailing,
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

  // ─── BOTTOM NAV ───────────────────────────────────────────

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
