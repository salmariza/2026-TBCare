import 'package:flutter/material.dart';
import 'widgets/dashboard_empty_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Variabel untuk simulasi data (nantinya ambil dari auth_service/database_service)
  bool hasMedicalData = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091413),
      // Memilih widget mana yang tampil berdasarkan ada/tidaknya data
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF091413), Color(0xFF0D1F1C), Color(0xFF163028)],
          ),
        ),
        child: SafeArea(
          child: hasMedicalData 
            ? const Center(child: Text("Halaman Loaded Data (Belum dibuat)", style: TextStyle(color: Colors.white))) // Nanti diganti dengan DashboardLoadedView
            : const DashboardEmptyView(),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xF20A1614),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFFB0E4CC),
          unselectedItemColor: Colors.white.withOpacity(0.3),
          selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_filled, 0),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.monitor_heart_outlined, 1),
              label: 'Pemantauan',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.history_outlined, 2),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, 3),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk membuat background hijau pada icon yang aktif
  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0x59285A48),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x33B0E4CC)),
            )
          : const BoxDecoration(),
      child: Icon(icon, size: 20),
    );
  }
}