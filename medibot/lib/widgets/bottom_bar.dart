import 'package:flutter/material.dart';
import 'package:medibot/screens/MyProfileScreen.dart';
import 'package:medibot/screens/signup.dart';
import '../screens/home_screen.dart';
import '../screens/medication_registration_screen.dart';
import '../screens/signup.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  // 네비게이션 탭에 연결할 화면들
  final List<Widget> _pages = [
    const HomeScreen(),
    const MedicationRegistrationScreen(), // TODO: 다른 화면 추가
    MyProfileScreen(), // TODO: 다른 화면 추가
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 현재 선택된 페이지 표시
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: '약물',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
