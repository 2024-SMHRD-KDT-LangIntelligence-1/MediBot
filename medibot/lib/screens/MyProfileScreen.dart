import 'package:flutter/material.dart';
import 'package:medibot/services/AuthService.dart';
import 'package:medibot/screens/LoginScreen.dart';
import 'package:medibot/screens/signup.dart';
import 'package:medibot/services/api_service.dart';
import 'package:medibot/screens/HelpScreen.dart';
import 'package:medibot/screens/privacy_screen.dart';
import 'package:medibot/screens/NotificationSettingsScreen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isLoggedIn = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    // _loadUserData();
  }

  Future<void> _checkLoginStatus() async {
    print("📡 [디버깅] 로그인 상태 확인 중..."); // ✅ 실행 여부 확인

    bool status = await AuthService.isLoggedIn();
    String? userId = await AuthService.getUserId(); // ✅ 로그인한 사용자 ID 가져오기
    print("📡 로그인 상태: $status, userId: $userId"); // ✅ 상태 확인

    setState(() {
      _isLoggedIn = status;
      _userId = userId; // ✅ 로그인한 사용자 ID 설정
    });
  }

  void _confirmAccountDeletion() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("정말로 탈퇴하시겠습니까?"),
            content: Text("계정을 삭제하면 모든 데이터가 복구되지 않습니다."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("취소"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // 닫기
                  await _deleteAccount(); // 실제 삭제
                },
                child: Text("탈퇴", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // ✅ 계정 삭제 API 호출
      await ApiService.deleteAccount(_userId!);

      // ✅ 탈퇴 후 로그인 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print("❌ 회원 탈퇴 실패: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("회원 탈퇴에 실패했습니다. 다시 시도해주세요.")));
    }
  }

  // void _loadUserData() async {
  //   String? storedUserId = await ApiService.getUserId();
  //   setState(() {
  //     _userId = storedUserId;
  //   });
  // }

  // ✅ 로그아웃 기능
  void _logout() async {
    await ApiService.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 배경을 부드러운 색상으로 변경
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

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // ✅ 왼쪽 정렬 (애플 스타일)
      children: [
        // ✅ 사용자 인사 메시지 (앱 상단에 배치)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "안녕하세요, 사용자 님 👋", // ✅ 사용자 ID 표시
                style: TextStyle(
                  fontSize: 22, // 🔽 크기 줄임
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "오늘도 건강한 하루 보내세요!",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        SizedBox(height: 15),

        // ✅ 사용자 프로필 정보 (아이콘 + 로그아웃 버튼)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // ✅ 프로필 아이콘
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40, // 🔽 크기 줄임
                      backgroundColor: Colors.indigoAccent.shade100,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ), // 🔽 아이콘 크기 조정
                    ),
                    SizedBox(width: 12), // 🔽 간격 줄임
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "내 계정",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ), // 🔽 크기 조정
                        ),
                        SizedBox(height: 3),
                        Text(
                          "설정을 확인하고 맞춤 기능을 이용하세요.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ), // 🔽 크기 조정
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // ✅ 설정 메뉴 (애플 스타일 리스트)
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Colors.grey.shade300,
                ), // 🔽 선 두께 줄임
                _buildListTile(Icons.notifications, "알림 설정", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                }),
                _buildListTile(Icons.lock, "개인정보 보호", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                  );
                }),
                _buildListTile(Icons.help_outline, "도움말 및 지원", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  );
                }),
                Divider(height: 1, thickness: 0.8, color: Colors.grey.shade300),

                SizedBox(height: 15),

                // ✅ 로그아웃 버튼
                TextButton(
                  onPressed: _logout,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size(double.infinity, 45), // 🔽 크기 조정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "로그아웃",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ), // 🔽 크기 조정
                  ),
                ),
                // ✅ 회원 탈퇴 버튼
                TextButton(
                  onPressed: _confirmAccountDeletion,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "회원 탈퇴",
                    style: TextStyle(fontSize: 14, color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ), // 🔽 패딩 줄임
      leading: Icon(icon, color: Colors.indigoAccent, size: 22), // 🔽 아이콘 크기 조정
      title: Text(title, style: TextStyle(fontSize: 14)), // 🔽 글자 크기 줄임
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ), // 🔽 크기 줄임
      onTap: onTap,
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
