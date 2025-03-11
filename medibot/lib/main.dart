import 'package:flutter/material.dart';
import 'widgets/bottom_bar.dart'; // 하단 네비게이션 바 추가

void main() {
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
