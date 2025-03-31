import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // 추가: Cupertino 패키지 임포트
import 'widgets/bottom_bar.dart'; // 하단 네비게이션 바 추가
import 'package:medibot/services/NotificationService.dart'; // 🔥 알림 서비스 추가
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await NotificationService.initNotifications(); // 🔥 앱 시작 시 알림 초기화 및 권한 요청
  AuthRepository.initialize(appKey: '5ee6076af595f4d8884d46e046f17e2e');

  // KakaoMapPlugin.init('b6ea247c7b4417edec15b21b3cac0183'); // 자바스크립트 키

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

// 예시: _buildIconButton 함수
Widget _buildIconButton(BuildContext context, bool isLoggedIn, Function onTap) {
  return GestureDetector(
    onTap: () {
      if (!isLoggedIn) {
        showDialog(
          context: context,
          builder:
              (context) => CupertinoAlertDialog(
                title: Text("로그인이 필요합니다"),
                content: Text("이 기능을 사용하려면 로그인이 필요해요."),
                actions: [
                  CupertinoDialogAction(
                    child: Text("확인"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
        );
      } else {
        onTap();
      }
    },
    child: Icon(Icons.alternate_email), // 아이콘 추가
  );
}
