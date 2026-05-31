import 'package:flutter/material.dart';

class MonitoringEditScreen extends StatefulWidget {
  const MonitoringEditScreen({super.key});

  @override
  State<MonitoringEditScreen> createState() => _MonitoringEditScreenState();
}

class _MonitoringEditScreenState extends State<MonitoringEditScreen> {
  final TextEditingController noteController = TextEditingController(
    text:
        "Aku hari ini ngerasa kalau sedikit panas, tapi aku udah minum obat tepat waktu",
  );

  final Map<String, bool> symptoms = {
    "Demam": true,
    "Batuk berkepanjangan": false,
    "Berat badan turun": false,
    "Keringat malam": false,
  };

  final Map<String, String> descriptions = {
    "Demam": "Suhu tubuh di atas 38°C",
    "Batuk berkepanjangan": "Batuk lebih dari 2 minggu",
    "Berat badan turun": "Berat badan turun tanpa sebab",
    "Keringat malam": "Keringat berlebih di malam hari",
  };

  int get selectedCount => symptoms.values.where((e) => e).length;

  Widget buildSectionTitle({
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

  Widget buildSymptomCard(String title) {
    final selected = symptoms[title]!;

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
                  descriptions[title]!,
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
            activeColor: const Color(0xFFB0E4CC),
            onChanged: (value) {
              setState(() {
                symptoms[title] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            "EDIT PEMANTAUAN HARIAN",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Bagaimana\nkabarmu hari ini?",
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
                      child: const Column(
                        children: [
                          Text(
                            "Rab",
                            style: TextStyle(
                              color: Color(0xFFB0E4CC),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "8",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            "Jan 2025",
                            style: TextStyle(
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
                buildSectionTitle(
                  icon: Icons.medication_outlined,
                  title: "Ceklis Harian",
                  subtitle: "Kepatuhan minum obat",
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0x55285A48), Color(0x33408A71)],
                    ),
                    border: Border.all(color: const Color(0x33B0E4CC)),
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
                              color: const Color(0x22B0E4CC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.medication,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Apakah kamu sudah minum obat hari ini?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Rifampicin · Isoniazid · Terjadwal 07:00",
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
                          color: Colors.grey.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),

                            SizedBox(width: 10),

                            Text(
                              "Ya, Sudah",
                              style: TextStyle(
                                color: Colors.white70,
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
                          color: const Color(0x14B0E4CC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: Color(0xFFB0E4CC),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Obat diminum pada 07.03",
                                style: TextStyle(
                                  color: Color(0xFFB0E4CC),
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            Icon(
                              Icons.check,
                              color: Color(0xFFB0E4CC),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // GEJALA
                buildSectionTitle(
                  icon: Icons.health_and_safety_outlined,
                  title: "Ceklis Gejala",
                  subtitle: "Edit gejala harian Anda",
                  trailing: "$selectedCount terpilih",
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
                      buildSymptomCard("Demam"),
                      buildSymptomCard("Batuk berkepanjangan"),
                      buildSymptomCard("Berat badan turun"),
                      buildSymptomCard("Keringat malam"),
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
                          "Jika gejala berlanjut, silakan hubungi dokter Anda.",
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
                buildSectionTitle(
                  icon: Icons.edit_note,
                  title: "Catatan Harian",
                  subtitle:
                      "Opsional — Ceritakan apa yang kamu rasakan hari ini",
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
                          hintText: "Tulis catatan harian...",
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

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Perubahan berhasil disimpan"),
                        ),
                      );
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
                          "Edit rekaman hari ini",
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

                const SizedBox(height: 18),

                Center(
                  child: Text(
                    "Data Anda bersifat pribadi dan tersimpan dengan aman.",
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
}
