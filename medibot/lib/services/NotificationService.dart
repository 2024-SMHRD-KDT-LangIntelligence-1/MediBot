import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:medibot/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("✅ 알림 클릭 감지됨! payload: ${response.payload}");
        _handleNotificationClick(response.payload); // ✅ 알림 클릭 이벤트 처리
      },
    );
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
      NotificationDetails(
        android: AndroidNotificationDetails(
          "medication_channel_id",
          "Medication Notifications",
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload:
          "$medicineName|${DateFormat('yyyy-MM-dd').format(time)}", // ✅ API 형식에 맞게 날짜 추가
    );
  }

  // ✅ 알림 클릭 시 실행되는 함수 (API 호출)
  static Future<void> _handleNotificationClick(String? payload) async {
    if (payload == null) return;

    List<String> data = payload.split('|');
    if (data.length != 2) return;

    String medicineName = data[0];
    String date = data[1];

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        throw Exception("🚨 사용자 ID 없음");
      }

      await ApiService.updateMedicationStatus(
        medicineName,
        true, // ✅ 클릭 시 자동으로 복약 체크 완료 (true)
        date,
      );

      print("✅ 복약 체크 완료: $medicineName ($date)");
    } catch (e) {
      print("🚨 복약 체크 업데이트 실패: $e");
    }
  }
}
