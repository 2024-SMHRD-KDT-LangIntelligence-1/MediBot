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

  // 📢 **✅ 1분 후 테스트 알람 스케줄링 추가**
  static Future<void> scheduleTestNotification(
    int id,
    String title,
    String body,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime testTime = now.add(Duration(minutes: 1)); // 🔥 현재 시간 + 1분 후

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(testTime, tz.local), // 🕒 1분 후 실행
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          '복약 알림',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ❌ 특정 알림 취소
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // ❌ 모든 알림 취소
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
