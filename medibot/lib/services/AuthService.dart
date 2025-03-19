import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = "authToken";
  static const String _baseUrl =
      "http://your-spring-boot-server.com"; // 🔥 스프링 부트 서버 주소

  // ✅ 회원가입 요청
  static Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return response.statusCode == 200;
  }

  // ✅ JWT 저장
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.containsKey('userId'); // ✅ userId가 있으면 true 반환
    print("📡 [디버깅] 로그인 상태 확인: $loggedIn");
    return loggedIn;
  }

  // ✅ 저장된 사용자 ID 가져오기
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId"); // userId 가져오기
  }

  // ✅ 로그아웃
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("userId");
    await prefs.setBool("isLoggedIn", false);
  }
}
