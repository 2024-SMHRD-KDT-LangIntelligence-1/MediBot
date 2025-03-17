import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl =
      "http://localhost:9090/api/auth"; // Spring Boot API 주소

  /// ✅ 이메일 중복 확인 API
  static Future<bool> checkEmailDuplicate(String userId) async {
    final url = Uri.parse('$baseUrl/check-email?userId=$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // true 또는 false 반환
    } else {
      throw Exception("이메일 중복 확인 실패");
    }
  }

  /// ✅ 회원가입 API
  static Future<String> signUp({
    required String userId,
    required String username,
    required String password,
    required int age,
    required String gender,
    required String wakeUpTime,
    required String sleepTime,
  }) async {
    final url = Uri.parse('$baseUrl/signup');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "username": username,
        "password": password,
        "age": age,
        "gender": gender, // "M" 또는 "F"
        "wakeUpTime": wakeUpTime, // "HH:mm:ss"
        "sleepTime": sleepTime,
      }),
    );

    if (response.statusCode == 200) {
      return "회원가입 성공!";
    } else {
      return "오류: ${response.body}";
    }
  }
}
