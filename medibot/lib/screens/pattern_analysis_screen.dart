import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PatternAnalysisScreen extends StatefulWidget {
  const PatternAnalysisScreen({Key? key}) : super(key: key);

  @override
  _PatternAnalysisScreenState createState() => _PatternAnalysisScreenState();
}

class _PatternAnalysisScreenState extends State<PatternAnalysisScreen> {
  Widget _generateTimeFeedback(String timeStr, String? predictedTimeFromAI) {
    final adjustedTime = _suggestAdjustedTime(timeStr);
    final hour = int.tryParse(timeStr.split(':')[0]) ?? 0;
    final suggestedTime =
        predictedTimeFromAI != null && predictedTimeFromAI.isNotEmpty
            ? predictedTimeFromAI
            : adjustedTime;

    final int? suggestedHour = int.tryParse(suggestedTime.split(':')[0] ?? '');
    String recommendationNote = "";

    // if (suggestedHour != null) {
    //   int diff = suggestedHour - hour;

    //   if (diff == 0) {
    //     recommendationNote = "AI도 동일한 시간대를 추천하고 있어요. 이 시간에 집중해보세요!";
    //   } else if (diff == 1) {
    //     recommendationNote = "AI는 이보다 1시간 후인 $suggestedTime에 복약하는 것을 추천해요.";
    //   } else if (diff == 2) {
    //     recommendationNote =
    //         "AI는 2시간 뒤인 $suggestedTime쯤 복약을 추천하고 있어요. 너무 늦지 않게 조정해보세요.";
    //   } else if (diff >= 3) {
    //     recommendationNote =
    //         "AI는 현재보다 꽤 늦은 $suggestedTime쯤 복약을 권장하고 있어요. 일정에 맞게 재조정이 필요해 보여요.";
    //   } else if (diff == -1) {
    //     recommendationNote =
    //         "AI는 1시간 이른 $suggestedTime쯤 복약을 추천하지만, 실제로는 이보다 늦게 복약을 시도하고 있어요. 알림을 $suggestedTime 전에 울리도록 조정해보세요.";
    //   } else if (diff == -2) {
    //     recommendationNote =
    //         "AI는 2시간 이른 $suggestedTime쯤 복약을 권장하고 있어요. 현재 루틴을 조금 앞당겨보는 걸 고려해보세요.";
    //   } else if (diff <= -3) {
    //     recommendationNote =
    //         "AI는 현재보다 훨씬 이른 $suggestedTime쯤 복약을 권장하고 있어요. 일과 전 루틴으로의 조정이 필요해 보여요.";
    //   }
    // }

    String message;
    if (hour >= 5 && hour < 8) {
      message = "이른 아침엔 준비로 바빠 놓치기 쉬우니, $suggestedTime쯤 복약하는 걸 추천해요.\n";
    } else if (hour >= 8 && hour < 12) {
      message = "오전 일정 중 복약을 잊지 않도록, 휴식 시간 전후인 $suggestedTime쯤 복약을 추천해요.\n";
    } else if (hour >= 12 && hour < 14) {
      message = "점심 시간 직후 여유 있는 시간인 $suggestedTime쯤 복약을 권장해요.\n";
    } else if (hour >= 14 && hour < 17) {
      message = "오후 집중력이 떨어지는 시간을 고려해, $suggestedTime쯤 복약을 추천하고 있어요.\n";
    } else if (hour >= 17 && hour < 20) {
      message = "퇴근 전후 분주한 시간을 피해 $suggestedTime쯤 복약하는 걸 추천해요.\n";
    } else if (hour >= 20 && hour < 24) {
      message = "하루 마무리 루틴에 맞춰 $suggestedTime쯤 복약하는 걸 권장해요.\n";
    } else {
      message = "새벽 시간대는 리듬이 깨지기 쉬우니, 생활 패턴에 맞춘 $suggestedTime쯤 복약을 추천해요.\n";
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: Colors.black),
        children: [
          TextSpan(
            text: "❗ 자주 놓치는 시간대: $timeStr\n",
            style: TextStyle(color: Colors.red),
          ),
          const TextSpan(
            text: "💡 AI는 ",
            style: TextStyle(color: Colors.indigo),
          ),
          TextSpan(text: message, style: const TextStyle(color: Colors.black)),
          if (recommendationNote.isNotEmpty)
            TextSpan(
              text: recommendationNote,
              style: const TextStyle(color: Colors.deepPurple),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> patternResult = [];
  List<int> weekdayCount = [];
  int avgDelay = 0;
  String mostCommonTime = '';
  int predictedSuccessRate = 0;
  String worstTime = '';
  String summaryMessage = '';
  Set<String> expandedDates = {};
  bool isRefreshing = false;
  String weekdayFailAnalysis = '';
  String delayDistributionAnalysis = '';
  String hourlySuccessAnalysis = '';
  String recommendedTimeAnalysis = '';
  int routineScore = 0;
  String? predictedTimeFromAI;

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

    try {
      predictedTimeFromAI = await ApiService.predictNextTime();
    } catch (e) {
      debugPrint("🚨 AI 예측 시간 불러오기 실패: $e");
    }

    setState(() {
      patternResult = resultList;
      avgDelay = avgDelayValue;
      mostCommonTime = mostCommon;
      weekdayCount = weekdayCountList;
      summaryMessage = _generateSummaryMessage(
        avgDelay,
        mostCommonTime,
        filtered.length,
        predictedTimeFromAI,
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
      if (predictedTimeFromAI != null && predictedTimeFromAI!.isNotEmpty) {
        final aiHour = int.tryParse(predictedTimeFromAI?.split(':')[0] ?? '');
        int minGap = 24;
        failCountByTime.forEach((key, value) {
          final failHour = int.tryParse(key.split(':')[0] ?? '');
          if (failHour != null && aiHour != null) {
            int gap = (failHour - aiHour).abs();
            if (gap < minGap) {
              minGap = gap;
              worst = key;
            }
          }
        });
      } else {
        int maxFails = 0;
        failCountByTime.forEach((key, value) {
          if (value > maxFails) {
            maxFails = value;
            worst = key;
          }
        });
      }
      worstTime = worst;

      // 요일별 실패율 분석
      List<int> failCountByWeekday = List.filled(7, 0);
      for (var entry in resultList) {
        final status = entry['status'];
        final dateStr = entry['date'];
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;
        final weekdayIndex = date.weekday % 7;
        if (status == '주의' || status == '심각') {
          failCountByWeekday[weekdayIndex]++;
        }
      }
      int maxFail = failCountByWeekday.reduce((a, b) => a > b ? a : b);
      int maxFailDayIndex = failCountByWeekday.indexOf(maxFail);
      const weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
      weekdayFailAnalysis =
          "📌 '${weekdayLabels[maxFailDayIndex]}'요일에 실패 비율이 가장 높아요. 해당 요일은 복약 알림을 조금 더 신경 써보세요.";

      // 지연 시간 분포 분석
      int over5min = filtered.where((e) => (e['delay'] as int) > 5).length;
      int delayPercent =
          filtered.isEmpty ? 0 : ((over5min / filtered.length) * 100).round();
      delayDistributionAnalysis =
          "⏳ 전체 복약 중 $delayPercent%가 5분 이상 지연되었어요. 알림 시간을 앞당기거나 습관을 조정해보세요.";

      // 시간대별 성공률 분석
      Map<int, int> successByHour = {};
      Map<int, int> totalByHour = {};
      for (var e in resultList) {
        final timeStr = e['time'];
        final status = e['status'];
        if (timeStr == null || status == null) continue;
        final hour = int.tryParse(timeStr.split(':')[0]) ?? 0;
        final bucket = (hour ~/ 3) * 3;
        totalByHour[bucket] = (totalByHour[bucket] ?? 0) + 1;
        if (status == '정상') {
          successByHour[bucket] = (successByHour[bucket] ?? 0) + 1;
        }
      }
      hourlySuccessAnalysis = '';
      successByHour.forEach((hour, count) {
        int total = totalByHour[hour] ?? 1;
        int rate = ((count / total) * 100).round();
        hourlySuccessAnalysis +=
            "🕒 ${hour.toString().padLeft(2, '0')}:00~ 성공률: $rate%\n";
      });

      // 루틴 점수 계산
      double consistency = mostCommonTime.isNotEmpty ? 100 : 50;
      routineScore =
          ((predictedSuccessRate * 0.6) +
                  ((100 - delayPercent) * 0.2) +
                  (consistency * 0.2))
              .round();

      // 추천 시간대
      recommendedTimeAnalysis =
          mostCommonTime.isNotEmpty
              ? "⏰ 평균적으로 $mostCommonTime쯤 복약했어요. 이 시간에 알림을 맞추는 것도 좋은 방법이에요."
              : "";
    });
  }

  String _generateSummaryMessage(
    int delay,
    String commonTime,
    int count,
    String? predictedTimeFromAI,
  ) {
    String baseMessage;

    if (count <= 2) {
      baseMessage = "데이터가 충분하지 않아요. 더 많은 복약 기록을 기다리며, 곧 더 정확한 분석을 제공할게요!";
    } else if (predictedSuccessRate >= 85) {
      baseMessage =
          "훌륭해요! 이번 주 복약 성공률은 $predictedSuccessRate%로, 거의 완벽한 복약 패턴을 보여주고 있어요. 계속 이대로라면 건강이 더욱 빛날 거예요.";
    } else if (predictedSuccessRate >= 70) {
      baseMessage =
          "좋은 성과에요! 이번 주 성공률은 $predictedSuccessRate%입니다. 약간의 조정으로 훨씬 더 안정적인 복약 루틴을 만들 수 있을 거예요.";
    } else if (predictedSuccessRate >= 50) {
      baseMessage =
          "분석 결과, 이번 주 복약 성공률은 $predictedSuccessRate%입니다. 개선의 여지가 보여요. 작은 습관 변화로 큰 변화를 만들어보세요.";
    } else {
      baseMessage =
          "이번 주 복약 성공률은 $predictedSuccessRate%입니다. 아직은 불규칙하지만, 지금부터 차근차근 개선해 나가면 분명 좋은 결과가 있을 거예요.";
    }

    // if (predictedTimeFromAI != null && predictedTimeFromAI.isNotEmpty) {
    //   final aiHour = int.tryParse(predictedTimeFromAI.split(':')[0] ?? '');
    //   final worstHour = int.tryParse(worstTime.split(':')[0] ?? '');

    //   if (aiHour != null &&
    //       worstHour != null &&
    //       (aiHour - worstHour).abs() <= 1) {
    //     baseMessage +=
    //         "\n\n💡 AI는 특히 ${predictedTimeFromAI}쯤 복약을 집중적으로 챙겨볼 것을 추천하고 있어요. 이 시간대는 자주 놓쳤던 시간과 겹치니, 특별히 주의해보세요.";
    //   } else {
    //     baseMessage +=
    //         "\n\n💡 AI는 특히 ${predictedTimeFromAI}쯤 복약을 집중적으로 챙겨볼 것을 추천하고 있어요.";
    //   }
    // }

    return baseMessage;
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
                        child: _generateTimeFeedback(
                          worstTime,
                          predictedTimeFromAI,
                        ),
                      ),
                    // 추가된 분석 위젯들
                    const SizedBox(height: 12),
                    Text(
                      weekdayFailAnalysis,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      delayDistributionAnalysis,
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "📈 AI 루틴 점수: $routineScore점",
                      style: const TextStyle(fontSize: 15),
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

String _suggestAdjustedTime(String timeStr) {
  try {
    final parts = timeStr.split(':');
    if (parts.length != 2) return timeStr;
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]) + 30;
    if (minute >= 60) {
      hour = (hour + 1) % 24;
      minute -= 60;
    }
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return "$h:$m";
  } catch (_) {
    return timeStr;
  }
}
