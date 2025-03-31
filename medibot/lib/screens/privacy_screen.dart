import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '개인정보 보호',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 인트로 카드
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: const [
                Icon(Icons.lock_outline, color: Colors.indigoAccent, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "MediBot은 사용자의 소중한 개인정보를 안전하게 보호합니다.",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const Text(
            "MediBot은 사용자의 개인정보 보호를 최우선으로 생각합니다.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          const Text(
            "1. 수집하는 정보",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "- 아이디, 비밀번호, 복약 일정 등 앱 사용을 위한 최소한의 정보만을 수집합니다.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          const Text(
            "2. 정보 사용 목적",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "- 맞춤형 복약 관리 및 알림 서비스를 제공하기 위한 목적으로만 사용됩니다.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          const Text(
            "3. 보안 및 암호화",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "- 모든 개인정보는 안전한 방식으로 암호화되어 저장됩니다.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          const Text(
            "4. 사용자 권리",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "- 언제든지 개인정보 열람, 수정, 삭제를 요청할 수 있습니다.",
            style: TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 30),

          const Text(
            "5. 이용약관",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "- 앱 이용 시 발생하는 모든 활동은 이용약관에 따르며, 위반 시 서비스 이용이 제한될 수 있습니다.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            "- 자세한 이용약관 내용은 별도의 링크 또는 설정 메뉴에서 확인할 수 있습니다.",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
