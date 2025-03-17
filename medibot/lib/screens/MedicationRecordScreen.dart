import 'package:flutter/material.dart';
import 'package:medibot/services/NotificationService.dart'; // 🔥 알림 서비스 추가

class MedicationRecordScreen extends StatefulWidget {
  const MedicationRecordScreen({super.key});

  @override
  _MedicationRecordScreenState createState() => _MedicationRecordScreenState();
}

class _MedicationRecordScreenState extends State<MedicationRecordScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 여기서 initNotifications()을 호출할 필요 없음 (main.dart에서 이미 실행됨)
  }

  void _requestPermissionManually() async {
    await NotificationService.requestPermissions(); // 🔥 수동으로 권한 요청
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("🔔 알림 권한 요청 완료!")));
  }

  void _scheduleTestNotification() {
    NotificationService.scheduleTestNotification(
      999, // 테스트용 ID
      "💊 복약 테스트 알림",
      "1분 후에 도착하는 테스트 알림입니다! 🚀",
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("📢 1분 후 테스트 알림이 예약되었습니다!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "복약 기록",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.blueAccent),
            onPressed: _requestPermissionManually, // 🔥 사용자가 직접 권한 요청 버튼 추가
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _scheduleTestNotification,
          child: Text("🕒 1분 후 알림 테스트"),
        ),
      ),
    );
  }
}
