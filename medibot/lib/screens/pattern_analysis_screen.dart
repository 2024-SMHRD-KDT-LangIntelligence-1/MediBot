import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PatternAnalysisScreen extends StatefulWidget {
  const PatternAnalysisScreen({Key? key}) : super(key: key);

  @override
  _PatternAnalysisScreenState createState() => _PatternAnalysisScreenState();
}

class _PatternAnalysisScreenState extends State<PatternAnalysisScreen> {
  List<Map<String, dynamic>> patternResult = [];
  List<int> weekdayCount = [];
  int avgDelay = 0;
  String mostCommonTime = '';
  int predictedSuccessRate = 0;
  String worstTime = '';
  String summaryMessage = '';
  Set<String> expandedDates = {};
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadPatternAnalysis();
  }

  Future<void> _loadPatternAnalysis() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 6));

    final resultList =
        (await ApiService.getPatternAnalysis()).where((e) {
          final dateStr = e['date'];
          if (dateStr == null) return false;
          final date = DateTime.tryParse(dateStr);
          if (date == null) return false;

          final dateOnly = DateTime(date.year, date.month, date.day);
          return dateOnly.isAtSameMomentAs(today) ||
              (dateOnly.isAfter(startDate) && !dateOnly.isAfter(today));
        }).toList();

    final filtered =
        resultList
            .where((e) => e['status'] != '정보 없음' && e['status'] != '미복용')
            .toList();

    final avgDelayValue =
        filtered.isEmpty
            ? 0
            : (filtered.map((e) => e['delay'] as int).reduce((a, b) => a + b) /
                    filtered.length)
                .round();

    final times = filtered.map((e) => e['time'] as String).toList();
    final mostCommon =
        times.isEmpty
            ? ''
            : times.reduce(
              (a, b) =>
                  times.where((v) => v == a).length >=
                          times.where((v) => v == b).length
                      ? a
                      : b,
            );

    final weekdayCountList = List.filled(7, 0);
    for (var entry in filtered) {
      try {
        final dateStr = entry['date'];
        if (dateStr == null) continue;
        final date = DateTime.parse(dateStr);
        final weekdayIndex = date.weekday % 7; // 일(0), 월(1), ..., 토(6)
        weekdayCountList[weekdayIndex]++;
      } catch (_) {
        continue;
      }
    }

    int successCount = resultList.where((e) => e['status'] == '정상').length;
    int totalCount = resultList.length;
    int successRate =
        totalCount == 0 ? 0 : ((successCount / totalCount) * 100).round();

    setState(() {
      patternResult = resultList;
      avgDelay = avgDelayValue;
      mostCommonTime = mostCommon;
      weekdayCount = weekdayCountList;
      summaryMessage = _generateSummaryMessage(
        avgDelay,
        mostCommonTime,
        filtered.length,
      );
      predictedSuccessRate = successRate;
      // 유독 실패가 많았던 시간 계산
      Map<String, int> failCountByTime = {};
      for (var entry in resultList) {
        final status = entry['status'];
        if (status == '주의' || status == '심각') {
          final time = entry['time'];
          if (time != null) {
            failCountByTime[time] = (failCountByTime[time] ?? 0) + 1;
          }
        }
      }
      String worst = '';
      int maxFails = 0;
      failCountByTime.forEach((key, value) {
        if (value > maxFails) {
          maxFails = value;
          worst = key;
        }
      });
      worstTime = worst;
    });
  }

  String _generateSummaryMessage(int delay, String commonTime, int count) {
    if (count <= 2) {
      return "아직 복약 데이터가 충분하지 않아요. 며칠 더 복용한 뒤 분석해볼게요!";
    } else if (delay.abs() <= 3) {
      return "'$commonTime'에 매우 정시 복약 중이에요! 훌륭한 습관이에요 👏";
    } else if (delay.abs() <= 7) {
      return "'$commonTime' 전후로 꾸준히 복약 중이에요. 안정적인 루틴을 유지하고 있어요.";
    } else if (delay.abs() <= 15) {
      return "'$commonTime'쯤 복약하려고 노력 중이네요. 알림을 설정해보면 더 정확해질 수 있어요.";
    } else if (delay.abs() <= 25) {
      return "복약 시간이 조금 불규칙해요. '$commonTime'에 복약 루틴을 다시 맞춰보는 건 어때요?";
    } else {
      return "복약 시간이 많이 흔들리고 있어요. '$commonTime'쯤에 맞춰 규칙적인 습관을 만들어보세요.";
    }
  }

  Color _getStatusColor(String status) {
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

  Widget _buildStatRow(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (var entry in patternResult) {
      final date = entry['date'] ?? '';
      if (date.isNotEmpty) {
        groupedByDate.putIfAbsent(date, () => []).add(entry);
      }
    }

    int normalCount = 0;
    int warningCount = 0;
    int dangerCount = 0;
    int missedCount = 0;

    for (var entry in patternResult) {
      final status = entry['status'] ?? '';
      switch (status) {
        case '정상':
          normalCount++;
          break;
        case '주의':
          warningCount++;
          break;
        case '심각':
          dangerCount++;
          break;
        default:
          missedCount++;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FC),
        foregroundColor: Colors.black,
        title: const Text("복약 패턴분석"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatternAnalysis,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 타이틀 + 새로고침
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "복약 패턴 분석",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  AnimatedRotation(
                    turns: isRefreshing ? 1 : 0,
                    duration: const Duration(seconds: 1),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.indigoAccent,
                      ),
                      onPressed: () async {
                        setState(() => isRefreshing = true);
                        await _loadPatternAnalysis();
                        setState(() => isRefreshing = false);
                      },
                    ),
                  ),
                ],
              ),

              // 🧠 AI 요약 카드
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 28, bottom: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🧠 AI 요약",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(summaryMessage, style: const TextStyle(fontSize: 15)),
                    if (worstTime.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          "❗ 자주 놓치는 시간대: $worstTime",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 📅 요일별 복약 통계 카드
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📅 요일별 복약 통계",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final label =
                            ['일', '월', '화', '수', '목', '금', '토'][index];
                        final count =
                            weekdayCount.length > index
                                ? weekdayCount[index]
                                : 0;
                        return Column(
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "$count회",
                              style: const TextStyle(
                                color: Colors.indigoAccent,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // 📊 최근 복약 통계 요약 카드
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "최근 복약 통계 요약",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatRow("✅ 정상 복약", "$normalCount회", Colors.green),
                    const SizedBox(height: 12),
                    _buildStatRow("⚠️ 주의 필요", "$warningCount회", Colors.orange),
                    const SizedBox(height: 12),
                    _buildStatRow("🚨 심각", "$dangerCount회", Colors.red),
                    const SizedBox(height: 12),
                    _buildStatRow("❌ 미복용/정보 없음", "$missedCount회", Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      "⏱ 평균 복용 지연: ${avgDelay}분",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "⏰ 가장 많이 복용한 시간대: $mostCommonTime",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),

              // 🔮 다음 주 예측 카드
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🔮 다음 주 예측",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "예상 복약 성공률: $predictedSuccessRate%",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),

              // 📅 날짜별 복약 내역 (카드 형태 유지)
              ...groupedByDate.entries.map((entry) {
                final date = entry.key;
                final meds = entry.value;
                final isExpanded = expandedDates.contains(date);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            expandedDates.remove(date);
                          } else {
                            expandedDates.add(date);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 24,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.indigoAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      ...meds.map((med) {
                        final name = med['mediName'] ?? med['name'] ?? '-';
                        final status = med['status'] ?? '-';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.medication_outlined,
                                  color: Colors.indigoAccent,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
