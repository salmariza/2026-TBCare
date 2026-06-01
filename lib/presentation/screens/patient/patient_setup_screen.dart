import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/database_service.dart';
import 'package:tbcare_app/data/services/notification_service.dart';
import 'package:tbcare_app/data/services/session_service.dart';

class PatientSetupScreen extends StatefulWidget {
  const PatientSetupScreen({super.key});

  @override
  State<PatientSetupScreen> createState() => _PatientSetupScreenState();
}

class _PatientSetupScreenState extends State<PatientSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();

  String selectedGender = "Perempuan";

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay _scheduleTime = const TimeOfDay(hour: 7, minute: 0);

  bool notificationEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final userName = SessionService.instance.currentUserName;
    if (userName != null) {
      nameController.text = userName;
    }
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  Future<void> pickScheduleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduleTime,
    );
    if (picked != null) {
      setState(() => _scheduleTime = picked);
    }
  }

  String get _scheduleDisplayText {
    return '${_scheduleTime.hour.toString().padLeft(2, '0')}:${_scheduleTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> savePatientData() async {
    final userId = SessionService.instance.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session tidak ditemukan. Silakan login ulang.")),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        medicineController.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data wajib diisi")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = DatabaseService.instance;

      final totalDays = endDate!.difference(startDate!).inDays + 1;
      final currentDay = DateTime.now().difference(startDate!).inDays + 1;

      await db.updateUser(userId, {
        'name': nameController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'gender': selectedGender,
      });

      await db.insertTreatmentPlan({
        'user_id': userId,
        'start_date':
            '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
        'end_date':
            '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}',
        'total_days': totalDays,
        'current_day': currentDay,
        'status': 'active',
        'reminder_enabled': notificationEnabled ? 1 : 0,
      });

      final medicineNames = medicineController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (medicineNames.isEmpty) {
        medicineNames.add(medicineController.text.trim());
      }

      for (final name in medicineNames) {
        await db.insertMedicine({
          'user_id': userId,
          'name': name,
          'dosage': '1 Tablet',
          'schedule': _scheduleDisplayText,
          'treatment_phase': 'Intensive',
          'frequency': 'daily',
        });
      }

      // Schedule daily reminder notification
      await NotificationService.instance
          .scheduleDailyReminder(_scheduleDisplayText);

      SessionService.instance.setUser(
        userId,
        nameController.text,
        SessionService.instance.currentUserEmail ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan")),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    medicineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091413),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Patient Setup",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Let's personalise your care plan",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              buildSectionTitle("Informasi Pribadi"),
              const SizedBox(height: 16),

              buildInput(
                controller: nameController,
                hint: "Nama Lengkap",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              buildInput(
                controller: ageController,
                hint: "Umur",
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              const Text(
                "Gender",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: genderCard("Laki-laki")),
                  const SizedBox(width: 12),
                  Expanded(child: genderCard("Perempuan")),
                ],
              ),
              const SizedBox(height: 28),

              buildSectionTitle("Informasi Perawatan"),
              const SizedBox(height: 16),

              buildDateCard(
                title: "Tanggal Mulai",
                value: startDate == null
                    ? "Pilih tanggal"
                    : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                onTap: pickStartDate,
              ),
              const SizedBox(height: 16),

              buildDateCard(
                title: "Tanggal Selesai",
                value: endDate == null
                    ? "Pilih tanggal"
                    : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                onTap: pickEndDate,
              ),
              const SizedBox(height: 16),

              buildInput(
                controller: medicineController,
                hint: "Nama Obat",
                icon: Icons.medication_outlined,
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  medicineChip("Rifampicin"),
                  medicineChip("Isoniazid"),
                  medicineChip("Pyrazinamide"),
                ],
              ),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: pickScheduleTime,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFB0E4CC)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jadwal Minum Obat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _scheduleDisplayText,
                              style: const TextStyle(
                                color: Color(0xFFB0E4CC),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white38,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFFB0E4CC),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pengingat",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Aktifkan notifikasi obat",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: notificationEnabled,
                      activeColor: const Color(0xFFB0E4CC),
                      onChanged: (value) {
                        setState(() => notificationEnabled = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : savePatientData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285A48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan & Lanjut",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget genderCard(String gender) {
    final isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() => selectedGender = gender);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0x33285A48)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB0E4CC)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: TextStyle(
              color: isSelected ? const Color(0xFFB0E4CC) : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateCard({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: Colors.white70),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget medicineChip(String text) {
    final medicines = medicineController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final isSelected = medicines.contains(text);

    return GestureDetector(
      onTap: () {
        setState(() {
          List<String> currentMedicines = medicineController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

          if (!currentMedicines.contains(text)) {
            currentMedicines.add(text);
          } else {
            currentMedicines.remove(text);
          }

          medicineController.text = currentMedicines.join(', ');
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isSelected ? const Color(0x33285A48) : const Color(0x0FB0E4CC),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB0E4CC)
                : const Color(0x33B0E4CC),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 14, color: Color(0xFFB0E4CC)),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFB0E4CC)
                    : const Color(0xB2B0E4CC),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
