import 'package:flutter/material.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  bool? hasTakenMedicine = true;

  final Map<String, bool> symptoms = {
    'Demam': true,
    'Batuk berkepanjangan': false,
    'Berat badan turun': false,
    'Keringat malam': false,
  };

  final TextEditingController noteController = TextEditingController(
    text: 'Aku hari ini ngerasa kalau sedikit panas, tapi aku udah minum obat tepat waktu',
  );

  int get selectedSymptomCount =>
      symptoms.values.where((value) => value).length;

  void showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091413),
      bottomNavigationBar: _bottomNav(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.17, 0.02),
            end: Alignment(1.17, 0.98),
            colors: [
              Color(0xFF091413),
              Color(0xFF0D1F1C),
              Color(0xFF163028),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 24),
                _sectionTitle(
                  icon: Icons.checklist_rounded,
                  title: 'Ceklis Harian',
                  subtitle: 'Kepatuhan minum obat',
                ),
                const SizedBox(height: 12),
                _medicineCard(),
                const SizedBox(height: 24),
                _symptomSection(),
                const SizedBox(height: 24),
                _noteSection(),
                const SizedBox(height: 24),
                _submitButton(),
                const SizedBox(height: 12),
                _privacyText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PEMANTAUAN HARIAN',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Bagaimana kabarmu hari ini?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x19B0E4CC),
            border: Border.all(color: const Color(0x26B0E4CC)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Text(
                'Rab',
                style: TextStyle(
                  color: Color(0xFFB0E4CC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '8',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Jan 2025',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0x4C285A48),
            border: Border.all(color: const Color(0x1EB0E4CC)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFB0E4CC), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.35,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _medicineCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.08, -0.11),
          end: Alignment(0.92, 1.11),
          colors: [Color(0x4C285A48), Color(0x26408A71)],
        ),
        border: Border.all(color: const Color(0x2DB0E4CC)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(Icons.medication_rounded),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apakah kamu sudah minum obat hari ini?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rifampicin · Isoniazid · Terjadwal 07:00',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _choiceButton(
                  label: 'Ya, Sudah',
                  icon: Icons.check_rounded,
                  selected: hasTakenMedicine == true,
                  onTap: () {
                    setState(() => hasTakenMedicine = true);
                    showInfo('Obat ditandai sudah diminum.');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _choiceButton(
                  label: 'Belum',
                  icon: Icons.close_rounded,
                  selected: hasTakenMedicine == false,
                  onTap: () {
                    setState(() => hasTakenMedicine = false);
                    showInfo('Obat ditandai belum diminum.');
                  },
                ),
              ),
            ],
          ),
          if (hasTakenMedicine == true) ...[
            const SizedBox(height: 14),
            _infoPill('Tandai sudah diminum pada 07.03'),
          ],
        ],
      ),
    );
  }

  Widget _choiceButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF285A48), Color(0xFF408A71)],
                )
              : null,
          color: selected ? null : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: selected ? const Color(0x66B0E4CC) : Colors.white10,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.white38,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _symptomSection() {
    return Column(
      children: [
        _sectionTitle(
          icon: Icons.health_and_safety_rounded,
          title: 'Ceklis Gejala',
          subtitle: 'Pilih semua yang sesuai hari ini',
          trailing: Text(
            '$selectedSymptomCount terpilih',
            style: const TextStyle(
              color: Color(0x7FB0E4CC),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _symptomTile(
                title: 'Demam',
                subtitle: 'Suhu tubuh di atas 38°C',
                icon: Icons.thermostat_rounded,
              ),
              _symptomTile(
                title: 'Batuk berkepanjangan',
                subtitle: 'Batuk lebih dari 2 minggu',
                icon: Icons.air_rounded,
              ),
              _symptomTile(
                title: 'Berat badan turun',
                subtitle: 'Berat badan turun tanpa sebab',
                icon: Icons.monitor_weight_rounded,
              ),
              _symptomTile(
                title: 'Keringat malam',
                subtitle: 'Keringat berlebih di malam hari',
                icon: Icons.nightlight_round,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _warningBox(),
      ],
    );
  }

  Widget _symptomTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected = symptoms[title] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => symptoms[title] = !selected);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0x38285A48)
                : Colors.white.withOpacity(0.03),
            border: Border.all(
              color: selected ? const Color(0x4CB0E4CC) : Colors.white10,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _iconBox(icon, selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white60,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: selected ? Colors.white38 : Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: selected,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF408A71),
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white12,
                onChanged: (value) {
                  setState(() => symptoms[title] = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noteSection() {
    return Column(
      children: [
        _sectionTitle(
          icon: Icons.edit_note_rounded,
          title: 'Catatan Harian',
          subtitle: 'Opsional — Ceritakan apa yang kamu rasakan hari ini',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              TextField(
                controller: noteController,
                maxLines: 5,
                maxLength: 500,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  counterStyle: const TextStyle(color: Colors.white24),
                  hintText: 'Tulis catatan harianmu...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFB0E4CC)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showInfo('Rekaman hari ini berhasil dikirim.');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.20, -1.06),
            end: Alignment(0.80, 2.06),
            colors: [Color(0xFF285A48), Color(0xFF3A7A60)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x7F285A48),
              blurRadius: 36,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.send_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kirim rekaman hari ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Rab, 8 January 2025',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xF20A1614),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Beranda', false, () {
            showInfo('Beranda ditekan.');
          }),
          _navItem(Icons.fact_check_rounded, 'Pemantauan', true, () {
            showInfo('Kamu sedang di halaman Pemantauan.');
          }),
          _navItem(Icons.history_rounded, 'Riwayat', false, () {
            showInfo('Riwayat ditekan.');
          }),
          _navItem(Icons.person_rounded, 'Profil', false, () {
            showInfo('Profil ditekan.');
          }),
        ],
      ),
    );
  }

  Widget _navItem(
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

  Widget _iconBox(IconData icon, {bool selected = true}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0x66285A48)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: selected ? const Color(0xFFB0E4CC) : Colors.white38,
        size: 20,
      ),
    );
  }

  Widget _infoPill(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x14B0E4CC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 14, color: Color(0xFFB0E4CC)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xB2B0E4CC),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x11FFB464),
        border: Border.all(color: const Color(0x1EFFB464)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0x7FFED7AA), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Jika gejala berlanjut, silakan hubungi dokter Anda.',
              style: TextStyle(
                color: Color(0x7FFED7AA),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyText() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_rounded, color: Colors.white24, size: 14),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            'Data Anda bersifat pribadi dan tersimpan dengan aman.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}