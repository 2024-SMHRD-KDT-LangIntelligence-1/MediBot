import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = "authToken";
  static const String _baseUrl =
      "http://your-spring-boot-server.com"; // 🔥 스프링 부트 서버 주소

  // ✅ 로그인 요청 (JWT 저장)
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)["token"];
      await _saveToken(token);
      return true;
    } else {
      return false;
    }
  }

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
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // ✅ JWT 불러오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ✅ 로그아웃 (토큰 삭제)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ✅ 로그인 여부 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
