import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:9090";

  static String convertGenderToEnum(String gender) {
    if (gender == "남성") return "M";
    if (gender == "여성") return "F";
    return "UNKNOWN"; // 예외 처리를 위해 기본값 추가
  }

  static Future<String> signUp({
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
      return response.body; // ✅ 성공 시 userId 반환
    } else {
      throw Exception("회원가입 실패: ${response.body}");
    }
  }

  static Future<MedicationSchedule> createSchedule({
    required String userId,
    required String mediName, // ✅ 약 이름
    required String tmDate, // YYYY-MM-DD 형식
    required String tmTime, // HH:mm 형식
    String tmDone = "N", // ✅ 기본값 'N' (미복용)
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/medication-schedules"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "mediName": mediName,
        "tmDate": tmDate,
        "tmTime": tmTime,
        "tmDone": tmDone,
        "realTmAt": null, // ✅ 실제 복용 시간 없음
      }),
    );

    if (response.statusCode == 200) {
      return MedicationSchedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("🚨 복약 일정 저장 실패: ${response.body}");
    }
  }

  /// **사용자의 복약 일정 목록 조회**
  static Future<List<MedicationSchedule>> getSchedulesByUser(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/medication-schedules/user/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => MedicationSchedule.fromJson(json)).toList();
    } else {
      throw Exception("🚨 복약 일정 조회 실패: ${response.body}");
    }
  }

  /// **특정 복약 일정 조회**
  static Future<MedicationSchedule> getScheduleById(int tmIdx) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/medication-schedules/$tmIdx"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return MedicationSchedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("🚨 일정 조회 실패: ${response.body}");
    }
  }

  /// **로그인 API**
  static Future<String> login({
    required String userId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "password": password}),
    );

    print("📡 [디버깅] 로그인 응답 코드: ${response.statusCode}");
    print("📡 [디버깅] 로그인 응답 본문: ${response.body}");

    if (response.statusCode == 200) {
      return response.body; // ✅ 성공 시 userId 반환
    } else {
      throw Exception("로그인 실패: ${response.body}");
    }
  }
}

class MedicationSchedule {
  final int? tmIdx; // ✅ 일정 ID
  final String? userId;
  final String? mediName; // ✅ 약 이름
  final String? tmDate; // YYYY-MM-DD
  final String? tmTime; // HH:mm
  final String? tmDone; // "Y" or "N"
  final String? realTmAt; // ✅ nullable 실제 복용 시간

  MedicationSchedule({
    required this.tmIdx,
    required this.userId,
    required this.mediName,
    required this.tmDate,
    required this.tmTime,
    required this.tmDone,
    this.realTmAt, // ✅ nullable
  });

  /// ✅ JSON → 객체 변환
  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      tmIdx: json["tm_idx"], // ✅ 일정 ID
      userId: json["user_id"],
      mediName: json["medi_name"], // ✅ 약 이름
      tmDate: json["tm_date"],
      tmTime: json["tm_time"],
      tmDone: json["tm_done"],
      realTmAt: json["real_tm_at"], // nullable
    );
  }

  /// ✅ 객체 → JSON 변환
  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "medi_name": mediName,
      "tm_date": tmDate,
      "tm_time": tmTime,
      "tm_done": tmDone,
      "real_tm_at": realTmAt, // nullable
    };
  }
}
