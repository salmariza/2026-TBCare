import 'package:flutter/material.dart';
import 'package:tbcare_app/data/services/session_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _bgColor = Color(0xFF091413);
  static const Color _accentColor = Color(0xFFB0E4CC);
  static const Color _primaryGreen = Color(0xFF285A48);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.only(bottom: 144),
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
              _bottomNav(context),
            ],
          ),
        ),
      ),
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
    return Container(
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
            _profileInfoRow(),
            const SizedBox(height: 12),
            _dividerLine(),
            const SizedBox(height: 12),
            _contactRow(),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatarWithBadge(),
        const SizedBox(width: 16),
        Expanded(child: _profileDetails()),
      ],
    );
  }

  Widget _avatarWithBadge() {
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
                child: Image.network(
                  'https://placehold.co/68x68',
                  fit: BoxFit.fill,
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

  Widget _profileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ridahas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 46,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 7,
                child: _profileBadge(
                  icon: Icons.calendar_today,
                  label: '45 Tahun',
                ),
              ),
              Positioned(
                left: 73,
                top: 14.75,
                child: _profileBadge(
                  icon: Icons.female,
                  label: 'Wanita',
                ),
              ),
              Positioned(
                left: 149.72,
                top: 14.50,
                child: _profileBadge(
                  icon: Icons.bloodtype,
                  label: 'O+',
                ),
              ),
            ],
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
        _contactItem(icon: Icons.phone, text: '+62 812 5129 1403'),
        const Spacer(),
        _contactItem(icon: Icons.location_on, text: 'Rungkut, Surabaya'),
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
    return SizedBox(
      height: 165.50,
      child: Row(
        children: [
          Expanded(child: _daysFulfilledCard()),
          const SizedBox(width: 12),
          Expanded(child: _complianceCard()),
        ],
      ),
    );
  }

  Widget _daysFulfilledCard() {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 18),
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
              const Text(
                'of 180',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '23',
            style: TextStyle(
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
          _miniProgressBar(widthFraction: 0.13),
          const SizedBox(height: 4),
          const Text(
            '12.8% dari keseluruhan',
            style: TextStyle(
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
              _changeBadge(),
            ],
          ),
          const Spacer(),
          _percentageText('98', '%'),
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
          _miniProgressBar(widthFraction: 0.80),
          const SizedBox(height: 4),
          const Text(
            'Performa sangat baik',
            style: TextStyle(
              color: Color(0xFFB0E4CC),
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _changeBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_upward, size: 10, color: Color(0xFFB0E4CC)),
        const SizedBox(width: 4),
        const Text(
          '+2%',
          style: TextStyle(
            color: Color(0xFFB0E4CC),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _percentageText(String number, String suffix) {
    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: -0.50,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            left: 37.89,
            top: 4,
            child: Text(
              suffix,
              style: const TextStyle(
                color: Color(0xFFB0E4CC),
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
          _treatmentPlanHeader(),
          const SizedBox(height: 12),
          _dividerLine(),
          const SizedBox(height: 12),
          _treatmentPlanStats(),
        ],
      ),
    );
  }

  Widget _treatmentPlanHeader() {
    return Row(
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
                  'Pengobatan DOTS 6 bulan',
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
        _phaseBadge(),
      ],
    );
  }

  Widget _phaseBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0x19B0E4CC),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0x33B0E4CC)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Fase 1',
        style: TextStyle(
          color: Color(0xFFB0E4CC),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _treatmentPlanStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem(value: '7', label: 'Hari\nStreak'),
        _verticalDivider(),
        _statItem(value: '22', label: 'Dosis\ndiminum'),
        _verticalDivider(),
        _statItem(value: '1', label: 'Dosis\nTerlewat'),
        _verticalDivider(),
        _statItem(value: '157', label: 'Hari\nTersisa'),
      ],
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
          _editProfileButton(),
          const SizedBox(height: 12),
          _logoutButton(context),
        ],
      ),
    );
  }

  Widget _editProfileButton() {
    return Container(
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
    );
  }

  Widget _logoutButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        SessionService.instance.clear();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
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
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
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
                onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
              ),
              _navItem(
                icon: Icons.fact_check_rounded,
                label: 'Pemantauan',
                isActive: false,
                onTap: () => Navigator.pushReplacementNamed(context, '/monitoring'),
              ),
              _navItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                isActive: false,
                onTap: () => Navigator.pushReplacementNamed(context, '/history'),
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
              color: isActive ? _accentColor : _white.withValues(alpha: 0.30),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? _accentColor : _white.withValues(alpha: 0.30),
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
