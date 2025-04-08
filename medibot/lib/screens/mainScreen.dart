import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medibot/screens/ChatBotScreen.dart';
import 'package:medibot/screens/NearbyMapScreen.dart';
import 'package:medibot/screens/home_screen.dart';
import 'package:medibot/screens/medication_registration_screen.dart';
import 'package:medibot/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:medibot/screens/drug_search_screen.dart';
import 'dart:convert';
import 'package:medibot/screens/pattern_analysis_screen.dart';
import 'package:medibot/screens/medication_schedule.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String summaryMessage = '';
  List<Map<String, dynamic>> todayMeds = [];
  List<Map<String, dynamic>> patternResult = [];
  Set<String> expandedDates = {};
  int avgDelay = 0;
  String mostCommonTime = '';
  bool isRefreshing = false;
  List<int> weekdayCount = [];
  int predictedSuccessRate = 0;
  String? userId;
  Map<String, String>? supplement1;
  Map<String, String>? supplement2;
  int? userInfoAge;
  String? userInfoGender;

  String? userAgeGroup;
  String? userGenderLabel;

  @override
  void initState() {
    super.initState();
    _loadTodayMeds();
    _loadPatternAnalysis(); // 추가
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("userId"); // userId가 null이면 비로그인
    });
    if (userId != null) _loadUserInfoAndRecommend(); // ✅ 추천 호출
  }

  void _loadUserInfoAndRecommend() async {
    try {
      final userInfo = await ApiService.getUserInfo(userId!);
      final int age = userInfo['age'];
      final String gender = userInfo['gender']; // ← 이거도 같이

      final ageGroup = _getAgeGroup(age);
      final fullList = _recommendSupplements(ageGroup, gender);
      final randomTwo = _getRandomTwo(fullList);

      setState(() {
        supplement1 = randomTwo[0];
        supplement2 = randomTwo[1];
        userInfoAge = age;
        userInfoGender = gender;
        userAgeGroup = ageGroup; // 예: "20대"
        userGenderLabel = gender; // 예: "남성"
      });
    } catch (e) {
      print("🚨 유저 정보 불러오기 실패: $e");
    }
  }

  String _getAgeGroup(int age) {
    if (age < 20) return "10대 이하";
    if (age < 30) return "20대";
    if (age < 40) return "30대";
    if (age < 50) return "40대";
    return "50대 이상";
  }

  List<Map<String, String>> _recommendSupplements(String age, String gender) {
    if (age == "20대" && gender == "남성") {
      return [
        {"name": "센트룸 포 맨", "desc": "에너지 활력, 면역력 강화"},
        {"name": "오메가3", "desc": "혈액순환, 눈 건강"},
        {"name": "아르기닌", "desc": "운동 능력 향상"},
        {"name": "비타민B", "desc": "피로 회복"},
        {"name": "루테인", "desc": "눈 피로 개선"},
        {"name": "프로바이오틱스", "desc": "장 건강"},
        {"name": "비타민D", "desc": "면역력 및 뼈 건강"},
      ];
    }

    if (age == "20대" && gender == "여성") {
      return [
        {"name": "철분 + 엽산", "desc": "빈혈 예방, 여성 건강"},
        {"name": "비오틴", "desc": "머릿결, 손톱 강화"},
        {"name": "콜라겐", "desc": "피부 탄력, 노화 방지"},
        {"name": "오메가3", "desc": "혈액순환, 두뇌 건강"},
        {"name": "종합비타민", "desc": "필수 영양소 보충"},
        {"name": "유산균", "desc": "장 건강 개선"},
        {"name": "비타민D", "desc": "면역력 및 뼈 건강"},
      ];
    }

    if (age == "30대" && gender == "남성") {
      return [
        {"name": "센트룸 포 맨", "desc": "기초 체력 보충"},
        {"name": "마그네슘", "desc": "근육 피로 개선"},
        {"name": "아연", "desc": "면역력 유지"},
        {"name": "오메가3", "desc": "심혈관 건강"},
        {"name": "비타민C", "desc": "항산화, 면역 강화"},
        {"name": "루테인", "desc": "눈 건강"},
        {"name": "유산균", "desc": "소화 기능 개선"},
      ];
    }

    if (age == "30대" && gender == "여성") {
      return [
        {"name": "철분 + 엽산", "desc": "피로 회복, 여성 건강"},
        {"name": "콜라겐", "desc": "피부 탄력, 노화 예방"},
        {"name": "칼슘", "desc": "뼈 건강"},
        {"name": "마그네슘", "desc": "근육, 신경 안정"},
        {"name": "크릴오일", "desc": "혈행 개선"},
        {"name": "비오틴", "desc": "모발 건강"},
        {"name": "종합비타민", "desc": "일상 필수 영양"},
      ];
    }

    if (age == "40대" && gender == "남성") {
      return [
        {"name": "비타민D", "desc": "뼈 건강, 면역력"},
        {"name": "루테인", "desc": "눈 건강"},
        {"name": "코엔자임 Q10", "desc": "심혈관 건강"},
        {"name": "마그네슘", "desc": "스트레스 개선"},
        {"name": "오메가3", "desc": "혈압, 콜레스테롤 관리"},
        {"name": "아연", "desc": "남성 기능 및 면역"},
        {"name": "프로폴리스", "desc": "호흡기 건강"},
      ];
    }

    if (age == "40대" && gender == "여성") {
      return [
        {"name": "칼슘 + 비타민D", "desc": "골다공증 예방"},
        {"name": "콜라겐", "desc": "피부 건강"},
        {"name": "크릴오일", "desc": "혈행 개선"},
        {"name": "비오틴", "desc": "모발, 손발톱 강화"},
        {"name": "마그네슘", "desc": "신경 안정"},
        {"name": "유산균", "desc": "소화 기능 향상"},
        {"name": "철분", "desc": "빈혈 예방"},
      ];
    }

    if (age == "50대 이상" && gender == "남성") {
      return [
        {"name": "오메가3", "desc": "심혈관 질환 예방"},
        {"name": "루테인", "desc": "황반변성 예방"},
        {"name": "코엔자임 Q10", "desc": "피로 개선"},
        {"name": "비타민D", "desc": "골다공증 예방"},
        {"name": "쏘팔메토", "desc": "전립선 건강"},
        {"name": "마그네슘", "desc": "혈압 안정화"},
        {"name": "종합비타민", "desc": "일상 영양 보충"},
      ];
    }

    if (age == "50대 이상" && gender == "여성") {
      return [
        {"name": "칼슘 + 비타민D", "desc": "골다공증 예방"},
        {"name": "이소플라본", "desc": "갱년기 증상 완화"},
        {"name": "크릴오일", "desc": "혈행 개선"},
        {"name": "루테인", "desc": "눈 건강"},
        {"name": "콜라겐", "desc": "피부 탄력"},
        {"name": "유산균", "desc": "소화 기능 향상"},
        {"name": "종합비타민", "desc": "기초 영양 보충"},
      ];
    }

    // 기본값
    return [
      {"name": "종합비타민", "desc": "기본적인 영양 보충"},
      {"name": "비타민C", "desc": "피로 회복, 면역력 유지"},
      {"name": "루테인", "desc": "눈 건강"},
      {"name": "오메가3", "desc": "혈액순환"},
      {"name": "비타민D", "desc": "면역력"},
      {"name": "유산균", "desc": "장 건강"},
      {"name": "아연", "desc": "면역세포 활성화"},
    ];
  }

  List<Map<String, String>> _getRandomTwo(List<Map<String, String>> list) {
    list.shuffle();
    return list.take(2).toList();
  }

  Future<void> _loadPatternAnalysis() async {
    try {
      final resultList = await ApiService.getPatternAnalysis();
      print("📦 패턴 분석 응답 샘플: ${jsonEncode(resultList.take(1).toList())}");
      setState(() {
        final now = DateTime.now();
        final oneWeekAgo = now.subtract(Duration(days: 7));
        final List<Map<String, dynamic>> filtered = [];

        for (var entry in resultList) {
          final dateStr = entry['date'] ?? '';
          try {
            final date = DateTime.parse(dateStr);
            if (date.isAfter(oneWeekAgo) &&
                date.isBefore(now.add(Duration(days: 1)))) {
              filtered.add({
                ...entry,
                'name': entry['mediName'] ?? entry['name'] ?? '-',
              });
            }
          } catch (_) {
            continue;
          }
        }

        filtered.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
        patternResult = filtered;

        // 📅 요일별 복약 횟수 계산
        weekdayCount = List.filled(7, 0);
        for (var entry in patternResult) {
          try {
            final date = DateTime.parse(entry['date']);
            if ((entry['status'] ?? '') == '정상') {
              weekdayCount[date.weekday % 7] += 1;
            }
          } catch (_) {}
        }

        // 💡 요약 메시지 생성
        final total = patternResult.length;
        final taken = patternResult.where((e) => e['status'] == '정상').length;
        final percent = total == 0 ? 0 : (taken / total * 100).round();
        summaryMessage =
            "총 ${patternResult.length}회 중 $taken회 복약 성공! ($percent%) 평균 지연: ${avgDelay}분";

        // 🔮 다음 주 예측 간단히 모델링
        predictedSuccessRate = percent;

        final validDelays =
            patternResult
                .where((e) => (e['delay'] ?? -1) != -1)
                .map((e) => e['delay'] as int)
                .toList();
        avgDelay =
            validDelays.isEmpty
                ? 0
                : (validDelays.reduce((a, b) => a + b) / validDelays.length)
                    .round();

        final timeCount = <String, int>{};
        for (var entry in patternResult) {
          final time = entry['time'];
          if (time != null) {
            timeCount[time] = (timeCount[time] ?? 0) + 1;
          }
        }
        mostCommonTime =
            timeCount.isNotEmpty
                ? (timeCount.entries.reduce(
                  (a, b) => a.value > b.value ? a : b,
                )).key
                : "없음";
      });
    } catch (e) {
      print("🚨 패턴 분석 실패: $e");
      setState(() {
        patternResult = [];
      });
    }
  }

  Future<void> _loadTodayMeds() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final meds = await ApiService.getMedicationRecords(today);
      setState(() {
        todayMeds = meds;
      });
    } catch (e) {
      print("🚨 복약 데이터 로딩 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              "MediBot",
              style: TextStyle(
                color: Colors.indigoAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 4),

            Image.asset(
              'assets/logo.png', // 로고 파일 경로
              height: 28,
            ),
          ],
        ),
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 16.0),
        //     child: Icon(Icons.notifications_none, color: Colors.black),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.asset("assets/banner.png"), // 배너 이미지 (추가 필요)
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconButton(
                  context,
                  // icon: null,
                  imageAsset: 'assets/logo_face_white.png', // 로고 이미지 경로
                  label: "챗봇",
                  onTap:
                      () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (_) => DraggableScrollableSheet(
                              initialChildSize: 0.9,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              expand: false,
                              builder: (context, scrollController) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: ChatBotScreen(),
                                );
                              },
                            ),
                      ),
                ),
                _buildIconButton(
                  context,
                  icon: Icons.add_box_outlined,
                  label: "복약약 등록",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicationRegistrationScreen(),
                        ),
                      ),
                ),
                _buildIconButton(
                  context,
                  icon: Icons.map_outlined,
                  label: "주변 약국",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KakaoMapPharmacyScreen(),
                        ),
                      ),
                ),
                _buildIconButton(
                  context,
                  icon: Icons.search,
                  label: "약 검색",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DrugSearchScreen(),
                      ),
                    );
                  },
                ),
                _buildIconButton(
                  context,
                  icon: Icons.analytics_outlined,
                  label: "복약 분석",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatternAnalysisScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "약 챙겨드세요",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            todayMeds.isEmpty
                ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "💊 오늘 먹을 약이 없어요",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "증상이 생기면 MediBot에게 바로 상담하세요!",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const MedicationRegistrationScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "약 등록하러 가기",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      todayMeds.map((med) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HomeScreen()),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      med['taken']
                                          ? Icons.check_circle
                                          : Icons.schedule,
                                      color:
                                          med['taken']
                                              ? Colors.green
                                              : Colors.indigoAccent,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          med['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "복용 시간: ${med['time']}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
            if (userId != null &&
                supplement1 != null &&
                supplement2 != null) ...[
              const SizedBox(height: 30),

              // ✅ 박스 밖 제목
              Text(
                "$userAgeGroup $userGenderLabel 맞춤 영양제 추천",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // ✅ 박스 내부는 깔끔한 리스트 스타일로
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 💊 추천 영양제 1
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          color: Colors.indigoAccent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplement1!['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                supplement1!['desc']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 💊 추천 영양제 2
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          color: Colors.indigoAccent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplement2!['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                supplement2!['desc']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
            const SizedBox(height: 12),
            const SizedBox(height: 30),

            const Text(
              "※ 본 앱은 일반적인 건강 정보를 제공하며, 전문적인 의학적 진단이나 치료를 대체하지 않습니다.\n정확한 의학적 판단을 위해 반드시 의료 전문가와 상담하시기 바랍니다.\n\n출처: 식품의약품안전처 의약품 개요 정보 (nedrug.mfds.go.kr)",
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    IconData? icon,
    String? imageAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (userId == null) {
          showDialog(
            context: context,
            builder:
                (context) => CupertinoAlertDialog(
                  title: Text("로그인이 필요합니다"),
                  content: Text("이 기능을 사용하려면 로그인이 필요해요."),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(),
                      isDefaultAction: true,
                      textStyle: const TextStyle(color: Colors.indigoAccent),
                      child: const Text("확인"),
                    ),
                  ],
                ),
          );
        } else {
          onTap();
        }
        // onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.indigoAccent,
            child:
                imageAsset != null
                    ? Image.asset(imageAsset, width: 35, height: 35)
                    : Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          Text("$count회", style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case '정상':
        return Colors.green;
      case '주의':
        return Colors.orange;
      case '심각':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
