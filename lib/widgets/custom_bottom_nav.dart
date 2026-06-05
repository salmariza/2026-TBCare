import 'package:flutter/material.dart';
import 'package:tbcare_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:tbcare_app/presentation/screens/monitoring/monitoring.dart';
import 'package:tbcare_app/presentation/screens/history/riwayat_pengobatan.dart';
import 'package:tbcare_app/presentation/screens/profile/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const DashboardScreen();
        break;
      case 1:
        page = const MonitoringPage();
        break;
      case 2:
        page = const HistoryPage();
        break;
      case 3:
        page = const ProfileScreen();
        break;
      default:
        page = const DashboardScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1614),
        border: Border(
          top: BorderSide(
            width: 1,
            color: Colors.white.withOpacity(0.07),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(context, 0, Icons.home_rounded, 'Beranda'),
            _buildNavItem(context, 1, Icons.monitor_heart_rounded, 'Pemantauan'),
            _buildNavItem(context, 2, Icons.receipt_long_rounded, 'Riwayat'),
            _buildNavItem(context, 3, Icons.person_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final bool isActive = currentIndex == index;

    if (isActive) {
      return GestureDetector(
        onTap: () => _onItemTapped(context, index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: const Color(0x59285A48),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0x33B0E4CC),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color(0xFFB0E4CC),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFB0E4CC),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _onItemTapped(context, index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.30),
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.30),
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ],
        ),
      );
    }
  }
}
