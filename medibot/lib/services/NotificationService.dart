import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ✅ 알림 초기화 + 권한 요청 강제 실행
  static Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notificationsPlugin.initialize(settings);
    tz.initializeTimeZones();

    await requestPermissions();
  }

  // 📢 **권한 요청 함수 (Android 13+ & iOS)**
  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied ||
          await Permission.notification.isPermanentlyDenied) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      print("📢 iOS 알람 권한 요청 결과: $result");
    }
  }

  static Future<void> scheduleMedicationNotification(
    int id,
    String medicineName,
    DateTime time,
  ) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      "💊 복약 시간 알림",
      "$medicineName 복용할 시간입니다.",
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "medication_channel_id",
          "Medication Notifications",
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간 알림
    );
  }
}
