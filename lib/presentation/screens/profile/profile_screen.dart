import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/database_service.dart';
import 'package:tbcare_app/data/services/session_service.dart';
import 'package:tbcare_app/widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _bgColor = Color(0xFF091413);
  static const Color _accentColor = Color(0xFFB0E4CC);
  static const Color _primaryGreen = Color(0xFF285A48);
  static const Color _white = Colors.white;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? _plan;
  int _streak = 0;
  int _dosesTaken = 0;
  int _dosesMissed = 0;
  int _totalDays = 180;
  int _remainingDays = 0;
  int _currentDay = 0;
  double _complianceRate = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = SessionService.instance.currentUserId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final db = DatabaseService.instance;
      final user = await db.getUser(userId);
      final plan = await db.getTreatmentPlan(userId);
      final streak = await db.calculateStreak(userId);

      // Use the same adherence calculation as the Treatment History page
      final stats = await db.getAdherenceStats(userId);
      final int taken = stats['taken'] as int;
      final int missed = stats['missed'] as int;
      final double complianceRate = (stats['complianceRate'] as num).toDouble();

      // Calculate plan stats — fall back to dummy plan for display when
      // no real plan exists.
      int totalDays = 180;
      int currentDay = 0;
      int remainingDays = 0;

      final effectivePlan = plan ?? (DatabaseService.useDummyData
          ? DatabaseService.getDummyTreatmentPlan()
          : null);

      if (effectivePlan != null) {
        totalDays = effectivePlan['total_days'] as int? ?? 180;
        final startStr = effectivePlan['start_date'] as String?;
        if (startStr != null) {
          final startDate = DateTime.tryParse(startStr);
          if (startDate != null) {
            currentDay = DateTime.now().difference(startDate).inDays + 1;
            remainingDays = totalDays - currentDay;
          }
        }
      }

      if (mounted) {
        setState(() {
          _user = user;
          _plan = effectivePlan;
          _streak = streak;
          _dosesTaken = taken;
          _dosesMissed = missed;
          _totalDays = totalDays;
          _currentDay = currentDay;
          _remainingDays = remainingDays < 0 ? 0 : remainingDays;
          _complianceRate = complianceRate;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    if (_user == null) return;

    final nameCtrl =
        TextEditingController(text: _user!['name'] as String? ?? '');
    final ageCtrl = TextEditingController(
        text: (_user!['age'] as int? ?? 0).toString());    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D1F1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0x33B0E4CC)),
              ),
              title: const Text('Edit Profil',
                  style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFB0E4CC)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Umur',
                        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFB0E4CC)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal',
                      style: TextStyle(color: Colors.white38)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await DatabaseService.instance.updateUser(
                      _user!['id'] as int,
                      {
                        'name': nameCtrl.text.trim(),
                        'age': int.tryParse(ageCtrl.text.trim()) ?? 0,
                      },
                    );
                    if (mounted) {
                      Navigator.pop(ctx);
                      await _loadProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A7A60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Simpan',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _genderOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0x33285A48) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFB0E4CC) : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                color: selected ? const Color(0xFFB0E4CC) : Colors.white70,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: const Center(
            child: CircularProgressIndicator(color: Color(0xFFB0E4CC))),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.20, 0.02),
            end: Alignment(1.20, 0.98),
            colors: [Color(0xFF091413), Color(0xFF0D1F1C), Color(0xFF163028)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _backgroundDecorations(),
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerSection(),
                    const SizedBox(height: 24),
                    _profileCard(),
                    const SizedBox(height: 24),
                    _treatmentSection(),
                    const SizedBox(height: 24),
                    _actionButtons(context),
                    const SizedBox(height: 24),
                    _footer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _backgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: 320,
            height: 320,
            decoration: ShapeDecoration(
              gradient: const RadialGradient(
                center: Alignment(0.50, 0.50),
                radius: 0.71,
                colors: [Color(0x72285A48), Color(0x00285A48)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
        Positioned(
          left: 87,
          top: 564,
          child: Container(
            width: 288,
            height: 288,
            decoration: ShapeDecoration(
              gradient: const RadialGradient(
                center: Alignment(0.50, 0.50),
                radius: 0.71,
                colors: [Color(0x0FB0E4CC), Color(0x00B0E4CC)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerTitles(),
              _notificationButton(),
            ],
          ),
          const SizedBox(height: 16),
          _dividerLine(),
        ],
      ),
    );
  }

  Widget _headerTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TB CARE',
          style: TextStyle(
            color: _white.withValues(alpha: 0.35),
            fontSize: 12,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.20,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Profil ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'Saya',
                style: TextStyle(
                  color: Color(0xFFB0E4CC),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Akun pasien & ringkasan pengobatan',
          style: TextStyle(
            color: _white.withValues(alpha: 0.35),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _notificationButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pushNamed(context, '/notification'),
      child: Container(
        width: 36,
        height: 36,
        decoration: ShapeDecoration(
          color: const Color(0x47285A48),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x19B0E4CC)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Icon(
          Icons.notifications_none,
          color: Color(0xFFB0E4CC),
          size: 18,
        ),
      ),
    );
  }

  Widget _dividerLine() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, 0.50),
          end: Alignment(1.00, 0.50),
          colors: [
            _white.withValues(alpha: 0),
            _white.withValues(alpha: 0.07),
            _white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    final name = _user?['name'] as String? ?? 'Pengguna';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: _white.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _white.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileInfoRow(name: name),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoRow({required String name}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatarWithBadge(name: name),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_user?['age'] != null)
                    _profileBadge(
                      icon: Icons.calendar_today,
                      label: '${_user!['age']} Tahun',
                    ),
                  if (_user?['gender'] != null &&
                      (_user!['gender'] as String).isNotEmpty)
                    _profileBadge(
                      icon: _user!['gender'] == 'Laki-laki'
                          ? Icons.male
                          : Icons.female,
                      label: _user!['gender'] as String,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
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

  Widget _avatarWithBadge({required String name}) {
    final initials = _getInitials(name);
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(3),
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(9999)),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              color: _bgColor,
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  color: const Color(0xFF285A48),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFFB0E4CC),
                        fontSize: 28,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 16,
            height: 16,
            decoration: ShapeDecoration(
              color: _primaryGreen,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2, color: Color(0xFF091413)),
                borderRadius: BorderRadius.all(Radius.circular(9999)),
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: Color(0xFFB0E4CC),
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0x2D285A48),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x1EB0E4CC)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: _accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB0E4CC),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow() {
    return Row(
      children: [
        _contactItem(icon: Icons.phone, text: '+62 ---'),
        const Spacer(),
        _contactItem(icon: Icons.email_outlined, text: 'tbcare@---'),
      ],
    );
  }

  Widget _contactItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _white.withValues(alpha: 0.40)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: _white.withValues(alpha: 0.40),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _treatmentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _treatmentHeader(),
          const SizedBox(height: 12),
          _treatmentStatsRow(),
          const SizedBox(height: 12),
          _treatmentPlanCard(),
        ],
      ),
    );
  }

  Widget _treatmentHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: ShapeDecoration(
            color: const Color(0x0FB0E4CC),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0x14B0E4CC)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Ringkasan Perawatan',
            style: TextStyle(
              color: Color(0xFFB0E4CC),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.30,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _dividerLine()),
      ],
    );
  }

  Widget _treatmentStatsRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _daysFulfilledCard()),
          const SizedBox(width: 12),
          Expanded(child: _complianceCard()),
        ],
      ),
    );
  }

  Widget _daysFulfilledCard() {
    final progressFraction = _totalDays > 0
        ? (_currentDay / _totalDays).clamp(0.0, 1.0)
        : 0.0;
    final progressPercent = (progressFraction * 100).toStringAsFixed(1);

    return Container(
      padding:
          const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 18),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.01, 0.01),
          end: Alignment(1.01, 0.99),
          colors: [Color(0x38285A48), Color(0x19408A71)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x23B0E4CC)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallIconBox(Icons.calendar_month),
              Text(
                'of $_totalDays',
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$_currentDay',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Hari Terpenuhi',
            style: TextStyle(
              color: _white.withValues(alpha: 0.40),
              fontSize: 11,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          _miniProgressBar(widthFraction: progressFraction),
          const SizedBox(height: 4),
          Text(
            '$progressPercent% dari keseluruhan',
            style: const TextStyle(
              color: Color(0xFFB0E4CC),
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _complianceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.01, 0.01),
          end: Alignment(1.01, 0.99),
          colors: [Color(0x38285A48), Color(0x19408A71)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x23B0E4CC)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallIconBox(Icons.trending_up),
              if (_complianceRate >= 80)
                _changeBadge(text: 'Baik', color: const Color(0xFF4ADE80))
              else if (_complianceRate >= 50)
                _changeBadge(text: 'Cukup', color: const Color(0xFFFFB464))
              else if (_complianceRate > 0)
                _changeBadge(text: 'Rendah', color: const Color(0xFFFF6E6E)),
            ],
          ),
          const Spacer(),
          _percentageText('${_complianceRate.round()}', '%'),
          const SizedBox(height: 2),
          Text(
            'Tingkat Kepatuhan',
            style: TextStyle(
              color: _white.withValues(alpha: 0.40),
              fontSize: 11,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          _miniProgressBar(
              widthFraction: (_complianceRate / 100).clamp(0.0, 1.0)),
          const SizedBox(height: 4),
          Text(
            _complianceRate >= 80
                ? 'Performa sangat baik'
                : _complianceRate >= 50
                    ? 'Perlu ditingkatkan'
                    : _complianceRate > 0
                        ? 'Butuh perhatian serius'
                        : 'Belum ada data',
            style: const TextStyle(
              color: Color(0xFFB0E4CC),
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _changeBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _percentageText(String number, String suffix) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            suffix,
            style: const TextStyle(
              color: Color(0xFFB0E4CC),
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniProgressBar({required double widthFraction}) {
    return SizedBox(
      height: 8,
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: ShapeDecoration(
              color: _white.withValues(alpha: 0.07),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFraction,
              child: Container(
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, 0.50),
                    end: Alignment(1.00, 0.50),
                    colors: [Color(0xFF285A48), Color(0xFFB0E4CC)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallIconBox(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: ShapeDecoration(
        color: const Color(0x47285A48),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x19B0E4CC)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Icon(icon, color: _accentColor, size: 16),
    );
  }

  Widget _treatmentPlanCard() {
    final status = _plan?['status'] as String? ?? 'active';
    final phase = _plan?['treatment_phase'] as String? ??
        (_currentDay <= 60 ? 'Fase Intensif' : 'Fase Lanjutan');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.15, -0.35),
          end: Alignment(0.85, 1.35),
          colors: [Color(0xE50F201E), Color(0xB2163028)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x19B0E4CC)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _smallIconBox(Icons.assignment),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rencana Perawatan',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pengobatan TBC',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: ShapeDecoration(
                  color: status == 'warning'
                      ? const Color(0x19FFB464)
                      : const Color(0x19B0E4CC),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1,
                        color: status == 'warning'
                            ? const Color(0x33FFB464)
                            : const Color(0x33B0E4CC)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  phase,
                  style: TextStyle(
                    color: status == 'warning'
                        ? const Color(0xFFFFB464)
                        : const Color(0xFFB0E4CC),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _dividerLine(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(value: '$_streak', label: 'Hari\nStreak'),
              _verticalDivider(),
              _statItem(value: '$_dosesTaken', label: 'Dosis\ndiminum'),
              _verticalDivider(),
              _statItem(value: '$_dosesMissed', label: 'Dosis\nTerlewat'),
              _verticalDivider(),
              _statItem(value: '$_remainingDays', label: 'Hari\nTersisa'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 42,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white.withValues(alpha: 0.30),
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 32,
      decoration: BoxDecoration(color: _white.withValues(alpha: 0.07)),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.21, -1.35),
                  end: Alignment(0.79, 2.35),
                  colors: [Color(0xFF285A48), Color(0xFF408A71)],
                ),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x33B0E4CC)),
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x66285A48),
                    blurRadius: 24,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 14),
                  SizedBox(width: 10),
                  Text(
                    'Edit Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _logoutButton(context),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        SessionService.instance.clear();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          color: _white.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _white.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: _white.withValues(alpha: 0.45), size: 14),
            const SizedBox(width: 10),
            Text(
              'Keluar',
              style: TextStyle(
                color: _white.withValues(alpha: 0.45),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'TB Care v2.1.0 · © 2026 Ministry of Health',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white.withValues(alpha: 0.20),
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Container(
          width: 375,
          padding:
              const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
          decoration: ShapeDecoration(
            color: const Color(0xF20A1614),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: _white.withValues(alpha: 0.07)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/dashboard'),
              ),
              _navItem(
                icon: Icons.fact_check_rounded,
                label: 'Pemantauan',
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/monitoring'),
              ),
              _navItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                isActive: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/history'),
              ),
              _navItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isActive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: isActive
            ? ShapeDecoration(
                color: const Color(0x59285A48),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x33B0E4CC)),
                  borderRadius: BorderRadius.circular(16),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? _accentColor
                  : _white.withValues(alpha: 0.30),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? _accentColor
                    : _white.withValues(alpha: 0.30),
                fontSize: isActive ? 12 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
