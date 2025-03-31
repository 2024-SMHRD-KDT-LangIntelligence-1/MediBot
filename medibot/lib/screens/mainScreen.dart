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
  bool isLoggedIn = false;

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
      isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    });
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
        title: const Text(
          "MediBot",
          style: TextStyle(
            color: Colors.indigoAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
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
                  icon: Icons.smart_toy_outlined,
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
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
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.indigoAccent,
            child: Icon(icon, color: Colors.white),
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
