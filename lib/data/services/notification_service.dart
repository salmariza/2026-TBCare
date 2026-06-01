import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Set from main.dart to enable notification tap → monitoring navigation
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigate to monitoring page when user taps the notification
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/monitoring',
      (route) => false,
    );
  }

  Future<void> scheduleDailyReminder(String scheduleTime) async {
    if (!_initialized) await initialize();

    // Cancel existing before rescheduling
    await _plugin.cancel(0);

    final parts = scheduleTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 7;
    final minute =
        int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    const androidDetails = AndroidNotificationDetails(
      'tbcare_reminder',
      'Pengingat Minum Obat',
      channelDescription:
          'Notifikasi pengingat minum obat TB setiap hari',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    // Calculate next occurrence
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time today has already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      '\u{1F48A} Pengingat Minum Obat',
      'Halo! Sudah waktunya minum obat TB hari ini.\n'
          'Jangan lupa buka TBCare dan isi pemantauan harian Anda.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllReminders() async {
    if (!_initialized) await initialize();
    await _plugin.cancel(0);
  }
}
