import 'package:flutter/material.dart';
import 'package:medibot/screens/ChatBotScreen.dart';
import 'package:medibot/screens/NearbyMapScreen.dart';
import 'package:medibot/screens/medication_registration_screen.dart';
import 'package:medibot/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:medibot/screens/drug_search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> todayMeds = [];

  @override
  void initState() {
    super.initState();
    _loadTodayMeds();
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
                        return Container(
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
                        );
                      }).toList(),
                ),
            const SizedBox(height: 30),
            const Text(
              "복약 패턴분석",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
      onTap: onTap,
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
}
