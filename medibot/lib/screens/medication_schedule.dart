import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medibot/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'MedicationDetailScreen.dart';
import 'ChatBotScreen.dart';
import 'package:medibot/services/NotificationService.dart'; // 🔥 알림 서비스 추가

class MedicationRecordScreen extends StatefulWidget {
  const MedicationRecordScreen({super.key});

  @override
  _MedicationRecordScreenState createState() => _MedicationRecordScreenState();
}

class _MedicationRecordScreenState extends State<MedicationRecordScreen> {
  DateTime _selectedDay = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _medicationsByTime = {};
  Set<String> _expandedTimes = {};
  Set<String> _loadingMedications = {};
  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMedicationRecords(); // ✅ 첫 빌드 직후 호출
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchMedicationRecords(); // ✅ 항상 데이터 새로 불러오기
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    _fetchMedicationRecords();
  }

  Future<void> _fetchMedicationRecords() async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
      List<Map<String, dynamic>> records =
          await ApiService.getMedicationRecords(formattedDate);

      Map<String, List<Map<String, dynamic>>> groupedRecords = {};
      for (var record in records) {
        String time = record["time"];
        if (!groupedRecords.containsKey(time)) {
          groupedRecords[time] = [];
        }
        groupedRecords[time]!.add(record);
      }

      setState(() {
        _medicationsByTime = groupedRecords;
      });

      await _scheduleMedicationNotifications();
    } catch (e) {
      print("🚨 복약 기록 불러오기 실패: $e");
    }
  }

  Future<void> _scheduleMedicationNotifications() async {
    _medicationsByTime.forEach((time, meds) {
      meds.forEach((med) {
        String medName = med["name"];
        DateTime medTime = DateFormat("HH:mm:ss").parse(time);
        DateTime now = DateTime.now();

        DateTime scheduleTime = DateTime(
          now.year,
          now.month,
          now.day,
          medTime.hour,
          medTime.minute,
        );

        if (scheduleTime.isBefore(now)) {
          scheduleTime = scheduleTime.add(Duration(days: 1));
        }

        NotificationService.scheduleMedicationNotification(
          med.hashCode,
          medName,
          scheduleTime,
        );
      });
    });
  }

  void _navigateToDetailScreen(String medName, String time) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MedicationDetailScreen(medName: medName, time: time),
      ),
    ).then((_) {
      // 💡 돌아왔을 때 복약 리스트 새로고침
      _fetchMedicationRecords();
    });
  }

  String _convertTimeFormat(String time) {
    DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);
    String period = parsedTime.hour < 12 ? "오전" : "오후"; // ✅ AM → 오전, PM → 오후 적용
    int hour =
        parsedTime.hour % 12 == 0 ? 12 : parsedTime.hour % 12; // 12시간 형식 변환
    return "$period $hour:${parsedTime.minute.toString().padLeft(2, '0')}"; // ✅ 00 분 형식 유지
  }

  Widget _buildMedicationList() {
    List<MapEntry<String, List<Map<String, dynamic>>>> sortedEntries =
        _medicationsByTime.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)); // ✅ 시간순 정렬 유지

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          sortedEntries.map((entry) {
            String time = entry.key;
            List<Map<String, dynamic>> medications = entry.value;
            bool isExpanded = _expandedTimes.contains(time);

            return Column(
              children: [
                // ✅ 시간 버튼 (배경색 추가)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded
                          ? _expandedTimes.remove(time)
                          : _expandedTimes.add(time);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.blueAccent,
                              size: 18,
                            ),
                            Text(
                              " ${_convertTimeFormat(time)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ 해당 시간대의 약 리스트
                if (isExpanded)
                  Column(
                    children:
                        medications.map((med) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              tileColor:
                                  med["taken"] ?? false
                                      ? Colors.indigoAccent.shade100
                                      : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              leading: GestureDetector(
                                onTap: () async {
                                  bool newValue = !(med["taken"] ?? false);
                                  String formattedDate = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(_selectedDay);

                                  setState(() {
                                    med["taken"] = newValue;
                                  });

                                  await _updateMedicationStatus(
                                    med["name"],
                                    newValue,
                                    formattedDate,
                                  );
                                },
                                child: Icon(
                                  med["taken"] ?? false
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color:
                                      med["taken"] ?? false
                                          ? Colors.blueAccent
                                          : Colors.grey.shade500,
                                ),
                              ),
                              title: Row(
                                children: [
                                  const Icon(
                                    Icons.medication,
                                    color: Colors.blueAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap:
                                        () => _navigateToDetailScreen(
                                          med["name"],
                                          time,
                                        ), // ✅ 상세 화면 이동
                                    child: Text(
                                      med["name"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  _openChatbotWithMedicineInfo(
                                    med["name"],
                                  ); // ✅ 챗봇 실행
                                },
                                child: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildRoundedCalendar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _selectedDay,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
          });
          _fetchMedicationRecords();
        },
        calendarFormat: CalendarFormat.week,
        daysOfWeekVisible: false,
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _openChatbotWithMedicineInfo(String medicineName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: ChatBotScreen(initialMessage: "이 $medicineName에 대한 정보를 알려줘."),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "복약 기록",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRoundedCalendar(),
            const SizedBox(height: 16),
            _buildMedicationList(),
          ],
        ),
      ),
    );
  }

  // ✅ 복약 체크 업데이트 (API 요청 성공 후 UI 업데이트)
  Future<void> _updateMedicationStatus(
    String medName,
    bool taken,
    String tmDate,
  ) async {
    if (_loadingMedications.contains(medName)) return; // ✅ 중복 요청 방지

    setState(() {
      _loadingMedications.add(medName);
    });

    try {
      await ApiService.updateMedicationStatus(medName, taken, tmDate);

      // ✅ UI 즉시 업데이트
      // setState(() {
      //   _medicationsByTime.forEach((time, meds) {
      //     for (var med in meds) {
      //       if (med["name"] == medName) {
      //         med["taken"] = taken;
      //       }
      //     }
      //   });
      // });

      // ✅ API 반영 후 다시 로드 (데이터 갱신)
      await _fetchMedicationRecords();
    } catch (e) {
      print("🚨 복약 상태 업데이트 실패: $e");
    } finally {
      setState(() {
        _loadingMedications.remove(medName);
      });
    }
  }
}
