import 'package:flutter/material.dart';
import 'widgets/bottom_bar.dart'; // 하단 네비게이션 바 추가
import 'package:medibot/services/NotificationService.dart'; // 🔥 알림 서비스 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await NotificationService.initNotifications(); // 🔥 앱 시작 시 알림 초기화 및 권한 요청

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BottomNavBar(), // 네비게이션 바 적용
    );
  }
}
