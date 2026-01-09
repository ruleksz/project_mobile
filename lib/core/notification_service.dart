import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    // HAPUS setLocalLocation('Asia/Jakarta').
    // Biarkan aplikasi mengikuti jam HP apa adanya.

    // TRIK: Gunakan '@drawable/launch_background'
    // Icon ini PASTI ADA di semua project Flutter Android.
    const androidInit = AndroidInitializationSettings(
      '@drawable/launch_background',
    );

    const settings = InitializationSettings(android: androidInit);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print("Notifikasi diklik: ${details.payload}");
      },
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // 1. Validasi: Jika waktu < 2 detik dari sekarang, anggap notifikasi langsung
    if (scheduledDate.isBefore(DateTime.now())) {
      // Opsional: Langsung tampilkan jika telat sedikit
      // await showImmediateNotification(id: id, title: title, body: body);
      return;
    }

    // 2. Buat Channel Baru (ID: 'channel_final_v9')
    // Ganti nama channel ini PENTING supaya HP mereset pengaturan yang error/silent.
    const androidDetails = AndroidNotificationDetails(
      'channel_final_v9',
      'Notifikasi Tugas',
      channelDescription: 'Pemberitahuan deadline',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/launch_background', // Pakai icon sistem yang pasti ada
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // 3. JADWALKAN (Gunakan wallClockTime)
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // WAJIB: Gunakan wallClockTime agar akurat sesuai jam di layar HP
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );

    print("JADWAL SUKSES: Notif ID $id akan muncul jam $scheduledDate");
  }

  static Future<void> showNow({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
