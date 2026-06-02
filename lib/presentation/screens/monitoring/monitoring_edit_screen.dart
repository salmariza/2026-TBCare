import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/database_service.dart';

class MonitoringEditScreen extends StatefulWidget {
  final int monitoringId;

  const MonitoringEditScreen({super.key, required this.monitoringId});

  @override
  State<MonitoringEditScreen> createState() => _MonitoringEditScreenState();
}

class _MonitoringEditScreenState extends State<MonitoringEditScreen> {
  Map<String, dynamic>? _monitoring;
  Map<String, dynamic>? _medicine;
  List<Map<String, dynamic>> _allSymptoms = [];
  final Map<int, bool> _selectedSymptoms = {};
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController noteController = TextEditingController();

  int get selectedCount =>
      _selectedSymptoms.values.where((e) => e).length;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = DatabaseService.instance;

      // Load monitoring record
      final monitoring = await db.getMonitoringById(widget.monitoringId);
      if (monitoring == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Load medicine info
      final medicineId = monitoring['medicine_id'] as int;
      final medicine = await db.getMedicineById(medicineId);

      // Load all symptoms
      final allSymptoms = await db.getAllSymptoms();

      // Initialize symptom selection
      for (final symptom in allSymptoms) {
        _selectedSymptoms[symptom['id']] = false;
      }

      // Load selected symptoms for this monitoring
      final selectedSymptoms =
          await db.getSymptomsForMonitoring(widget.monitoringId);
      for (final symptom in selectedSymptoms) {
        _selectedSymptoms[symptom['id']] = true;
      }

      // Load note
      if (monitoring['note'] != null &&
          (monitoring['note'] as String).isNotEmpty) {
        noteController.text = monitoring['note'] as String;
      }

      if (mounted) {
        setState(() {
          _monitoring = monitoring;
          _medicine = medicine;
          _allSymptoms = allSymptoms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _saveEdit() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final db = DatabaseService.instance;

      // Update monitoring record
      await db.updateMonitoring(widget.monitoringId, {
        'note': noteController.text,
      });

      // Update symptom links
      await db.deleteSymptomsForMonitoring(widget.monitoringId);
      for (final entry in _selectedSymptoms.entries) {
        if (entry.value) {
          await db.insertMonitoringSymptom(widget.monitoringId, entry.key);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan')),
        );
        Navigator.pushReplacementNamed(context, '/monitoring');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get _medicineDisplayText {
    if (_medicine == null) return '-';
    return _medicine!['name'] as String? ?? '-';
  }

  String get _medicineSchedule {
    if (_medicine == null) return '07:00';
    return _medicine!['schedule'] as String? ?? '07:00';
  }

  String get _dateHeaderDay {
    if (_monitoring == null) return '';
    final dateStr = _monitoring!['date'] as String?;
    if (dateStr == null) return '';
    try {
      final parts = dateStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      return days[date.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  String get _dateHeaderDayNum {
    if (_monitoring == null) return '';
    final dateStr = _monitoring!['date'] as String?;
    if (dateStr == null) return '';
    try {
      final parts = dateStr.split('-');
      return parts[2];
    } catch (_) {
      return '';
    }
  }

  String get _dateHeaderMonthYear {
    if (_monitoring == null) return '';
    final dateStr = _monitoring!['date'] as String?;
    if (dateStr == null) return '';
    try {
      final parts = dateStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

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

    if (_monitoring == null || _medicine == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF091413),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Data tidak ditemukan',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF091413),

      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF091413), Color(0xFF0D1F1C), Color(0xFF163028)],
            ),
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 120,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EDIT PEMANTAUAN HARIAN',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Bagaimana\nkabarmu hari ini?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 72,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0x22B0E4CC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x33B0E4CC)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _dateHeaderDay,
                            style: const TextStyle(
                              color: Color(0xFFB0E4CC),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _dateHeaderDayNum,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            _dateHeaderMonthYear,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // DAILY CHECK
                _buildSectionTitle(
                  icon: Icons.medication_outlined,
                  title: 'Ceklis Harian',
                  subtitle: 'Status minum obat tidak dapat diubah',
                ),

                const SizedBox(height: 14),

                Builder(builder: (context) {
                  final isLate =
                      _monitoring!['status'] == 'taken_late';

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: isLate
                            ? [const Color(0x557A5A20), const Color(0x33998040)]
                            : [const Color(0x55285A48), const Color(0x33408A71)],
                      ),
                      border: Border.all(
                        color: isLate
                            ? const Color(0x33FFB464)
                            : const Color(0x33B0E4CC),
                      ),
                    ),

                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isLate
                                    ? const Color(0x22FFB464)
                                    : const Color(0x22B0E4CC),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.medication,
                                color: isLate
                                    ? const Color(0xFFFFB464)
                                    : Colors.white,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Apakah kamu sudah minum obat hari ini?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    '$_medicineDisplayText · Terjadwal $_medicineSchedule',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: isLate
                                ? const Color(0xFF7A5A20)
                                : const Color(0xFF3A7A60),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isLate
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isLate ? 'Ya, Sudah (Terlambat)' : 'Ya, Sudah',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isLate
                                ? const Color(0x22FFB464)
                                : const Color(0x14B0E4CC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: isLate
                                    ? const Color(0xFFFFB464)
                                    : const Color(0xFFB0E4CC),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  _monitoring!['taken_at'] != null
                                      ? 'Obat diminum pada ${_formatTakenTime(_monitoring!['taken_at'] as String)}'
                                      : 'Obat sudah diminum',
                                  style: TextStyle(
                                    color: isLate
                                        ? const Color(0xFFFFB464)
                                        : const Color(0xFFB0E4CC),
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              Icon(
                                isLate
                                    ? Icons.warning_amber_rounded
                                    : Icons.check,
                                color: isLate
                                    ? const Color(0xFFFFB464)
                                    : const Color(0xFFB0E4CC),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 28),

                // SYMPTOMS
                _buildSectionTitle(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Ceklis Gejala',
                  subtitle: 'Edit gejala harian Anda',
                  trailing: '$selectedCount terpilih',
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),

                  child: Column(
                    children: [
                      ..._allSymptoms.map((symptom) {
                        return _buildSymptomCard(
                          symptomId: symptom['id'],
                          title: symptom['name'] as String,
                          description: symptom['description'] as String? ?? '',
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x11FFB464),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x22FFB464)),
                  ),

                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Color(0xFFFFD28B),
                        size: 18,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Jika gejala berlanjut, silakan hubungi dokter Anda.',
                          style: TextStyle(
                            color: Color(0xFFFFD28B),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // NOTE
                _buildSectionTitle(
                  icon: Icons.edit_note,
                  title: 'Catatan Harian',
                  subtitle:
                      'Opsional — Ceritakan apa yang kamu rasakan hari ini',
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveEdit,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7A60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSaving ? Icons.hourglass_empty : Icons.edit,
                          color: Colors.white,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: Text(
                    'Data Anda bersifat pribadi dan tersimpan dengan aman.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.20),
                      fontSize: 11,
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

  String _formatTakenTime(String takenAtStr) {
    try {
      final dt = DateTime.parse(takenAtStr);
      return '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return takenAtStr;
    }
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0x33285A48),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x22B0E4CC)),
          ),
          child: Icon(icon, color: const Color(0xFFB0E4CC), size: 18),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 2),

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

        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              color: Color(0x99B0E4CC),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildSymptomCard({
    required int symptomId,
    required String title,
    required String description,
  }) {
    final selected = _selectedSymptoms[symptomId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0x33285A48)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? const Color(0x55B0E4CC)
              : Colors.white.withOpacity(0.08),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0x55285A48)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white70,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withOpacity(0.65),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: selected,
            activeThumbColor: const Color(0xFFB0E4CC),
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
}
