import 'package:flutter/material.dart';

class StorageManager {
  static final StorageManager _instance = StorageManager._internal();

  factory StorageManager() {
    return _instance;
  }

  StorageManager._internal();

  Map<String, dynamic> _storage = {
    "user": {}, // 회원가입 정보 저장
    "gender": "", // 성별 저장
    "sleepSchedule": {}, // 취침 & 기상 시간 저장
    "medicationTimes": [], // 약 복용 시간 리스트 저장
    "medications": {}, // 시간별 선택한 약 리스트
  };

  // ✅ 회원가입 정보 저장
  void saveUserInfo(
    String name,
    String email,
    String password,
    String? birthdate,
  ) {
    _storage["user"] = {
      "name": name,
      "email": email,
      "password": password,
      "birthdate": birthdate,
    };
    print("📌 [저장 완료] 회원가입 정보: $_storage");
  }

  // ✅ 성별 저장
  void saveGender(String? gender) {
    _storage["gender"] = gender;
    print("📌 [저장 완료] 성별: $_storage");
  }

  // ✅ 기상 & 취침 시간 저장
  void saveSleepSchedule(TimeOfDay wakeUpTime, TimeOfDay bedTime) {
    _storage["sleepSchedule"] = {
      "wakeUp": "${wakeUpTime.hour}:${wakeUpTime.minute}",
      "bedTime": "${bedTime.hour}:${bedTime.minute}",
    };
    print("📌 [저장 완료] 기상 & 취침 시간: $_storage");
  }

  // ✅ 약 복용 시간 저장
  void saveMedicationTime(List<Map<String, dynamic>> times) {
    _storage["medicationTimes"] = times;
    print("📌 [저장 완료] 약 복용 시간 리스트: $_storage");
  }

  // ✅ 시간별 선택한 약 저장
  void saveSelectedMedications(String time, List<String> medicationList) {
    _storage["medications"][time] = medicationList;
    print("📌 [저장 완료] ${time} 시간에 선택된 약: $medicationList");
  }

  // ✅ 저장된 모든 데이터 가져오기
  Map<String, dynamic> getAllData() {
    return _storage;
  }
}
