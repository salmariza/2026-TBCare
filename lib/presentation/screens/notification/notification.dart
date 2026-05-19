import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  final List<Map<String, String>> notifications = const [
    {
      'title': 'Waktunya minum obat',
      'time': '07:00 · Hari ini',
      'message': 'Jangan lupa minum obat hari ini',
    },
    {
      'title': 'Waktunya minum obat',
      'time': '07:00 · Kemarin',
      'message': 'Jangan lupa minum obat hari ini',
    },
    {
      'title': 'Waktunya minum obat',
      'time': '07:00 · 27 Jan',
      'message': 'Jangan lupa minum obat hari ini',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091413),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.20, 0.02),
            end: Alignment(1.20, 0.98),
            colors: [
              Color(0xFF091413),
              Color(0xFF0D1F1C),
              Color(0xFF163028),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _backButton(context),
                const SizedBox(height: 14),
                _header(),
                const SizedBox(height: 24),
                ...notifications.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _notificationCard(
                      title: item['title']!,
                      time: item['time']!,
                      message: item['message']!,
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

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TB CARE',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w300,
            height: 1.33,
            letterSpacing: 1.20,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Daftar notifikasi saya',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w300,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0),
                Colors.white.withOpacity(0.07),
                Colors.white.withOpacity(0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _notificationCard({
    required String title,
    required String time,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.04, -0.05),
          end: Alignment(0.96, 1.05),
          colors: [
            Color(0x2D285A48),
            Color(0x14408A71),
          ],
        ),
        border: Border.all(color: const Color(0x23B0E4CC)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFFB0E4CC),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                  height: 1.50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontStyle: FontStyle.italic,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
                height: 1.63,
              ),
            ),
          ),
        ],
      ),
    );
  }
}