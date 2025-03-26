import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = "http://localhost:9090";
  static const String baseUrl = "http://192.168.219.47:9090";

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

    // print("📡 [디버깅] 로그인 응답 코드: ${response.statusCode}");
    // print("📡 [디버깅] 로그인 응답 본문: ${response.body}");

    if (response.statusCode == 200) {
      return response.body; // ✅ 성공 시 userId 반환
    } else {
      throw Exception("로그인 실패: ${response.body}");
    }
  }

  // ✅ 저장된 로그인 정보 가져오기
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  // ✅ 로그아웃 (저장된 로그인 정보 삭제)
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("userId");
    await prefs.setBool("isLoggedIn", false);
  }

  // ✅ 복약 기록 가져오기
  static Future<List<Map<String, dynamic>>> getMedicationRecords(
    String date,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId"); // ✅ 로그인된 사용자 ID 가져오기

    if (userId == null) {
      throw Exception("사용자 ID 없음");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/medication-schedules/user/$userId?date=$date"),
      headers: {"Content-Type": "application/json"},
    );
    // print("📡 [디버깅] 복약 기록 요청 - userId: $userId, date: $date");
    // print("📡 [디버깅] 복약 기록 응답 코드: ${response.statusCode}");
    // print("📡 [디버깅] 복약 기록 응답 데이터: ${response.body}");

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      // print("📡 [디버깅] 복약 기록 응답 데이터: $decodedBody");

      List<dynamic> data = jsonDecode(decodedBody);
      return data
          .map(
            (item) => {
              "name": item["mediName"], // ✅ 약 이름
              "time": item["tmTime"], // ✅ 복약 시간
              "taken": item["tmDone"] == true, // ✅ boolean 값 처리
            },
          )
          .toList();
    } else {
      throw Exception("복약 기록 불러오기 실패: ${response.body}");
    }
  }

  static Future<void> updateMedicationStatus(
    String mediName,
    bool isTaken,
    String tmDate, // ✅ 날짜 추가
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      throw Exception("사용자 ID 없음");
    }

    final response = await http.put(
      Uri.parse("$baseUrl/api/medication-schedules/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "mediName": mediName,
        "tmDate": tmDate, // ✅ 날짜도 함께 보냄
        "tmDone": isTaken, // ✅ true/false 상태 업데이트
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("🚨 복약 상태 업데이트 실패: ${response.body}");
    }
  }

  /// **📌 특정 약 + 시간에 대한 복용일자 조회 (첫날 ~ 마지막날)**
  static Future<Map<String, String>> getMedicationDateRange(
    String mediName,
    String tmTime,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      throw Exception("🚨 사용자 ID 없음");
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/medication-schedules/dates?userId=$userId&mediName=$mediName&tmTime=$tmTime",
      ),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "startDate": data["startDate"] ?? "정보 없음",
        "endDate": data["endDate"] ?? "정보 없음",
      };
    } else {
      throw Exception("🚨 복용일자 조회 실패: ${response.body}");
    }
  }

  /// **📌 특정 약 삭제 (같은 약 전체 삭제)**
  static Future<void> deleteMedication(String mediName, String tmTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      throw Exception("🚨 사용자 ID 없음");
    }

    final response = await http.delete(
      Uri.parse(
        "$baseUrl/api/medication-schedules/delete?userId=$userId&mediName=$mediName&tmTime=$tmTime",
      ),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("🚨 복약 일정 삭제 실패: ${response.body}");
    }
  }

  /// **📌 복약 시간 수정**
  static Future<void> updateMedicationTime(
    String mediName,
    String oldTime,
    String newTime,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    // print("📡 [디버깅] 복약 시간 수정 요청: $mediName, $oldTime -> $newTime");

    if (userId == null) {
      throw Exception("🚨 사용자 ID 없음");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/api/medication-schedules/update-time"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "mediName": mediName,
        "oldTime": oldTime,
        "newTime": newTime,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("🚨 복약 시간 수정 실패: ${response.body}");
    }
  }

  static Future<List<String>> searchDrugByName(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/drug-info/search?name=${Uri.encodeQueryComponent(query)}',
        ),
      );

      print("📡 요청 URL: $baseUrl/api/drug-info/search?name=$query");
      print("📡 응답 코드: ${response.statusCode}");
      print("📡 응답 본문: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        print("🟢 검색 결과 리스트: ${data.length}개");
        return data.map<String>((item) => item.toString()).toList();
      } else {
        throw Exception('❌ 약 정보 검색 실패: ${response.body}');
      }
    } catch (e) {
      print("🚨 예외 발생: $e");
      return [];
    }
  }

  static Future<DrugInfo?> fetchDrugDetailByName(String name) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/drug-info/detail?name=${Uri.encodeQueryComponent(name)}',
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        print(
          "🟢 [API 응답] 약 정보 (Pretty):\n${const JsonEncoder.withIndent('  ').convert(data)}",
        );
        if (data.isNotEmpty) {
          return DrugInfo.fromJson(data[0]); // 첫 번째 약 정보만 사용
        }
      }
      return null;
    } catch (e) {
      print("🚨 약 상세 정보 로딩 실패: $e");
      return null;
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

class DrugInfo {
  final String mediName;
  final String? sideEffectsFromRepo;
  final String? mediInter; // ✅ 추가

  DrugInfo({required this.mediName, this.sideEffectsFromRepo, this.mediInter});

  factory DrugInfo.fromJson(Map<String, dynamic> json) {
    return DrugInfo(
      mediName: json['mediName'] ?? '',
      sideEffectsFromRepo: json['sideEffectsFromRepo'],
      mediInter: json['mediInter'], // ✅ 매핑
    );
  }
}
