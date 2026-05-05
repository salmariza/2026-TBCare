import 'dart:ui';
import 'package:flutter/material.dart';

class PatientSetupScreen extends StatefulWidget {
  const PatientSetupScreen({super.key});

  @override
  State<PatientSetupScreen> createState() => _PatientSetupScreenState();
}

class _PatientSetupScreenState extends State<PatientSetupScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  String gender = 'Laki-laki';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    ageController = TextEditingController();
    weightController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> _savePatientData() async {
    final name = nameController.text.trim();
    final age = ageController.text.trim();
    final weight = weightController.text.trim();

    if (name.isEmpty || age.isEmpty || weight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua data pasien terlebih dahulu')),
      );
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data pasien berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0d3a3a),
              const Color(0xFF1a5555),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Data Pasien',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Isi informasi dasar untuk membantu personalisasi perawatan TB Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.65),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a6a6a).withOpacity(0.17),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFF6abaaa).withOpacity(0.18),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nama',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildGlassField(
                                controller: nameController,
                                hintText: 'cth. Putri',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Umur',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildGlassField(
                                controller: ageController,
                                hintText: 'cth. 28',
                                icon: Icons.calendar_today_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Jenis Kelamin',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildGenderDropdown(),
                              const SizedBox(height: 20),
                              const Text(
                                'Berat Badan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildGlassField(
                                controller: weightController,
                                hintText: 'cth. 55 kg',
                                icon: Icons.monitor_weight_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _savePatientData,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4a9a9a),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4a9a9a).withOpacity(0.24),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Simpan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.white.withOpacity(0.55),
              size: 20,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF6abaaa).withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF6abaaa).withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF6abaaa).withOpacity(0.35),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF1a5555).withOpacity(0.28),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a5555).withOpacity(0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6abaaa).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: gender,
          isExpanded: true,
          dropdownColor: const Color(0xFF1a5555).withOpacity(0.95),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white.withOpacity(0.7),
          ),
          items: const [
            DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              gender = value;
            });
          },
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          selectedItemBuilder: (context) {
            return const [
              Text('Laki-laki'),
              Text('Perempuan'),
            ];
          },
        ),
      ),
    );
  }
}
