import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:medibot/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
// import 'package:android_intent_plus/android_intent_plus.dart';

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

  // static Future<void> requestExactAlarmPermission() async {
  //   if (Platform.isAndroid && Platform.version.compareTo('12') >= 0) {
  //     final intent = AndroidIntent(
  //       action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  //     );
  //     await intent.launch();
  //   }
  // }

  static final List<String> _messages = [
    "오늘도 건강 잘 챙기고 계시네요 😊",
    "한 알의 약, 큰 건강 🌿",
    "시간 맞춰 복용하는 습관, 멋져요!",
    "작은 습관이 큰 건강을 만듭니다.",
    "잘하고 있어요! 계속 이렇게만!",
    "복약 시간이에요! 건강을 위한 한 걸음 🏃",
    "꾸준함은 최고의 치료제입니다 💊",
    "몸도 마음도 오늘도 챙겨보세요 ☀️",
    "이 약은 당신을 위한 응원이에요 🙌",
    "잠깐! 약 챙기셨나요? 😌",
  ];

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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(time.year, time.month, time.day);

    if (today != targetDate) {
      print(
        "🚫 오늘 일정 아님 → 알림 예약 안 함: $medicineName (${DateFormat('yyyy-MM-dd').format(time)})",
      );
      return;
    }

    // ✅ 랜덤 멘트 선택
    final message =
        _messages[DateTime.now().millisecondsSinceEpoch % _messages.length];

    final scheduledTime = tz.TZDateTime.from(time, tz.local);

    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print("🚫 예약 시간 이미 지남 → 알림 예약 안 함: $medicineName ($scheduledTime)");
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      "💊 복약 시간 알림",
      "$medicineName 복용할 시간입니다.\n$message",
      scheduledTime,
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
      matchDateTimeComponents: null,
      payload: "$medicineName|${DateFormat('yyyy-MM-dd').format(time)}",
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
