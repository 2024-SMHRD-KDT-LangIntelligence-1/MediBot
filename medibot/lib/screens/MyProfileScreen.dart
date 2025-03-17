import 'package:flutter/material.dart';
import 'package:medibot/services/AuthService.dart';
import 'package:medibot/screens/LoginScreen.dart';
import 'package:medibot/screens/signup.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool status = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = status;
    });
  }

  void _logout() async {
    await AuthService.logout();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // ✅ 배경을 부드러운 색상으로 변경
      appBar: AppBar(
        title: Text(
          "내 정보",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: _isLoggedIn ? _buildUserInfo() : _buildLoginPrompt(),
        ),
      ),
    );
  }

  // ✅ 로그인된 경우 (부드러운 카드 UI 적용)
  Widget _buildUserInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueAccent.shade100,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 12),
              Text(
                "사용자님, 반가워요! 👋",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                "내 정보 및 설정을 확인하세요.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text("로그아웃", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ 로그인되지 않은 경우 (트렌디한 스타일 적용)
  Widget _buildLoginPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 80,
          color: Colors.indigoAccent,
        ), // 🔒 아이콘 추가
        SizedBox(height: 20),
        Text(
          "로그인이 필요합니다",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "MediBot의 모든 기능을 사용하려면 로그인하세요.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        SizedBox(height: 30),

        // 🎯 카드 스타일 버튼 컨테이너
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // 🔴 로그인 버튼 (iOS 스타일)
              ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "로그인",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 12),

              // 🔵 회원가입 버튼 (Outlined 스타일)
              OutlinedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignUpScreen()),
                    ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  "회원가입",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
