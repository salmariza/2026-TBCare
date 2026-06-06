import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      // Use dummy data for demo (June 1-8, 2026)
      final notifications = _dummyNotifications();

      // Sort descending by date (most recent first)
      notifications.sort((a, b) {
        final aDate = _parseDummyDate(a['time'] as String);
        final bDate = _parseDummyDate(b['time'] as String);
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _parseDummyDate(String timeLabel) {
    // timeLabel format: "09:00 · 1 Jun" or "09:00 · 8 Jun"
    try {
      final datePart = timeLabel.split('·').last.trim(); // "1 Jun"
      final parts = datePart.split(' ');
      final day = int.parse(parts[0]);
      const months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'Mei': 5, 'Jun': 6,
        'Jul': 7, 'Agu': 8, 'Sep': 9, 'Okt': 10, 'Nov': 11, 'Des': 12,
      };
      final month = months[parts[1]] ?? 6;
      return DateTime(2026, month, day);
    } catch (_) {
      return DateTime(2026, 1, 1);
    }
  }

  List<Map<String, dynamic>> _dummyNotifications() {
    return [
      // --- June 3, 2026 (Rabu) ---
      {
        'title': 'Waktunya minum obat',
        'message': 'Pengingat harian: Minum obat TB sesuai jadwal pagi',
        'time': '07:00 · 3 Jun',
        'type': 'reminder',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFB0E4CC),
      },
      // --- June 4, 2026 (Kamis) ---
      {
        'title': 'Waktunya minum obat',
        'message': 'Pengingat harian: Minum obat TB sesuai jadwal pagi',
        'time': '07:00 · 4 Jun',
        'type': 'reminder',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFB0E4CC),
      },
      // --- June 5, 2026 (Jumat) ---
      {
        'title': 'Waktunya minum obat',
        'message': 'Pengingat harian: Minum obat TB sesuai jadwal pagi',
        'time': '07:00 · 5 Jun',
        'type': 'reminder',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFB0E4CC),
      },
      // --- June 6, 2026 (Sabtu) ---
      {
        'title': 'Waktunya minum obat',
        'message': 'Pengingat harian: Minum obat TB sesuai jadwal pagi',
        'time': '07:00 · 6 Jun',
        'type': 'reminder',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFB0E4CC),
      },
      // --- June 7, 2026 (Minggu) ---
      /*{
        'title': 'Waktunya minum obat',
        'message': 'Pengingat harian: Minum obat TB sesuai jadwal pagi',
        'time': '09:00 · 7 Jun',
        'type': 'reminder',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFB0E4CC),
      },
      // --- June 8, 2026 (Senin) ---
      {
        'title': 'Waktunya minum obat',
        'message': 'Pengingat harian: Minum obat TB sesuai jadwal pagi',
        'time': '09:00 · 8 Jun',
        'type': 'reminder',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFB0E4CC),
      },*/
    ];
  }

  String _formatTimeLabel(String schedule) {
    final now = DateTime.now();
    final parts = schedule.split(':');
    final hour = int.tryParse(parts[0]) ?? 7;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    if (now.isBefore(scheduled)) {
      return '$schedule · Hari ini';
    } else {
      final diff = now.difference(scheduled);
      if (diff.inMinutes < 60) {
        return '$schedule · ${diff.inMinutes} menit lalu';
      } else {
        return '$schedule · Hari ini';
      }
    }
  }

  String _formatMissedDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return dateStr;
    }
  }

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
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFFB0E4CC),
                      ),
                    ),
                  )
                else if (_notifications.isEmpty)
                  _emptyState()
                else
                  ..._notifications.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _notificationCard(item),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.notifications_off_rounded,
                color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text(
              'Tidak ada notifikasi',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
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
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
        Text(
          '${_notifications.length} notifikasi',
          style: const TextStyle(
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
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.07),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final icon = item['icon'] as IconData;
    final color = item['color'] as Color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.04, -0.05),
          end: const Alignment(0.96, 1.05),
          colors: type == 'warning'
              ? [const Color(0x2D7A5A20), const Color(0x14998040)]
              : [const Color(0x2D285A48), const Color(0x14408A71)],
        ),
        border: Border.all(
          color: type == 'warning'
              ? const Color(0x23FFB464)
              : const Color(0x23B0E4CC),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['title'] as String,
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
                item['time'] as String,
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
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item['message'] as String,
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
