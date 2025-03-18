import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:9090";

  static String convertGenderToEnum(String gender) {
    if (gender == "남성") return "M";
    if (gender == "여성") return "F";
    return "UNKNOWN"; // 예외 처리를 위해 기본값 추가
  }

  static Future<int> signUp({
    required String userId,
    required String username,
    required String password,
    required String birthdate, // ✅ 생년월일 추가 (YYYY-MM-DD)
    required String gender,
    required String wakeUpTime,
    required String sleepTime,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "username": username,
        "password": password,
        "birthdate": birthdate, // ✅ YYYY-MM-DD 형식 전달
        "gender": convertGenderToEnum(gender),
        "wakeUpTime": wakeUpTime,
        "sleepTime": sleepTime,
      }),
    );

    if (response.statusCode == 200) {
      return int.parse(response.body); // ✅ 성공 시 userId 반환
    } else {
      throw Exception("회원가입 실패: ${response.body}");
    }
  }

  static Future<MedicationSchedule> createSchedule({
    required String userId,
    required int mediIdx, // ✅ 약 ID
    required String tmDate, // YYYY-MM-DD 형식
    required String tmTime, // HH:mm 형식
    String tmDone = "N", // ✅ 기본값 'N' (미복용)
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/medications/schedule"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "mediIdx": mediIdx,
        "tmDate": tmDate,
        "tmTime": tmTime,
        "tmDone": tmDone, // 기본값: 'N' (미복용)
      }),
    );

    if (response.statusCode == 200) {
      return MedicationSchedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("🚨 복약 일정 저장 실패: ${response.body}");
    }
  }

  static Future<int> addMedication({
    required String userId,
    required String mediType, // ✅ 약 이름 (DB 컬럼과 일치)
    String mediDesc = "", // ✅ 설명 (선택)
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/medications/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "mediType": mediType, // ✅ 백엔드 필드와 일치
        "mediDesc": mediDesc, // 설명 (기본값: 빈 문자열)
      }),
    );

    if (response.statusCode == 200) {
      return int.parse(response.body); // 저장된 약 ID 반환
    } else {
      throw Exception("🚨 약 저장 실패: ${response.body}");
    }
  }
}

class MedicationSchedule {
  final int tmIdx; // ✅ 일정 ID
  final String userId;
  final int mediIdx; // ✅ 약 ID
  final String tmDate; // YYYY-MM-DD
  final String tmTime; // HH:mm
  final String tmDone; // "Y" or "N"

  MedicationSchedule({
    required this.tmIdx,
    required this.userId,
    required this.mediIdx,
    required this.tmDate,
    required this.tmTime,
    required this.tmDone,
  });

  /// ✅ JSON → 객체 변환
  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      tmIdx: json["tm_idx"], // ✅ 일정 ID
      userId: json["user_id"],
      mediIdx: json["medi_idx"],
      tmDate: json["tm_date"],
      tmTime: json["tm_time"],
      tmDone: json["tm_done"],
    );
  }

  /// ✅ 객체 → JSON 변환
  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "medi_idx": mediIdx,
      "tm_date": tmDate,
      "tm_time": tmTime,
      "tm_done": tmDone,
    };
  }
}
