import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../dashboard/dashboard_screen.dart';

class PatientSetupScreen extends StatefulWidget {
  const PatientSetupScreen({super.key});

  @override
  State<PatientSetupScreen> createState() => _PatientSetupScreenState();
}

class _PatientSetupScreenState extends State<PatientSetupScreen> {
  // =========================
  // CONTROLLER
  // =========================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();

  String selectedGender = "Perempuan";

  DateTime? startDate;
  DateTime? endDate;

  bool notificationEnabled = true;

  // =========================
  // DATE PICKER
  // =========================

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  // =========================
  // SAVE DATA
  // =========================

  Future<void> savePatientData() async {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        medicineController.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi")));
      return;
    }

    try {
      final db = await DatabaseService.instance.database;

      // =========================
      // SAVE USER
      // =========================

      await db.insert('user', {
        'name': nameController.text,
        'email': '',
        'password': '',
      });

      // =========================
      // SAVE MEDICINE
      // =========================

      await db.insert('medicine', {
        'name': medicineController.text,
        'dosage': '1 Tablet',
        'schedule': '07:00',
      });

      // =========================
      // SAVE MONITORING
      // =========================

      await db.insert('monitoring', {
        'medicine_id': 1,
        'status': 'Belum Minum',
        'date': DateTime.now().toString(),
      });

      // =========================
      // SUCCESS
      // =========================

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // =========================
  // UI
  // =========================

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

              // =========================
              // HEADER
              // =========================
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

              // =========================
              // PERSONAL INFO
              // =========================
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

              // =========================
              // CARE INFO
              // =========================
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

              const SizedBox(height: 28),

              // =========================
              // NOTIFICATION
              // =========================
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
                        setState(() {
                          notificationEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed: savePatientData,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285A48),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: const Text(
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

  // =========================
  // COMPONENTS
  // =========================

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
        setState(() {
          selectedGender = gender;
        });
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
