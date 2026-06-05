import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  static const Color bgColor = Color(0xFF091413);
  static const Color accentColor = Color(0xFFB0E4CC);
  static const Color primaryGreen = Color(0xFF285A48);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 78,

      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          navItem(icon: Icons.home_outlined, title: "Beranda", index: 0),

          navItem(
            icon: Icons.monitor_heart_outlined,
            title: "Pemantauan",
            index: 1,
          ),

          navItem(icon: Icons.history, title: "Riwayat", index: 2),

          navItem(icon: Icons.person, title: "Profil", index: 3),
        ],
      ),
    );
  }

  Widget navItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool active = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),

            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: active
                  ? primaryGreen.withOpacity(0.3)
                  : Colors.transparent,

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,

              color: active ? accentColor : Colors.white.withOpacity(0.4),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,

            style: TextStyle(
              color: active ? accentColor : Colors.white.withOpacity(0.4),

              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
