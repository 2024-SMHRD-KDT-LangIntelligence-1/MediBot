// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:medibot/services/api_service.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:intl/intl.dart';
// import 'MedicationDetailScreen.dart';
// import 'ChatBotScreen.dart';
// import 'package:medibot/services/NotificationService.dart'; // 🔥 알림 서비스 추가

// class MedicationRecordScreen extends StatefulWidget {
//   const MedicationRecordScreen({super.key});

//   @override
//   _MedicationRecordScreenState createState() => _MedicationRecordScreenState();
// }

// class _MedicationRecordScreenState extends State<MedicationRecordScreen> {
//   DateTime _selectedDay = DateTime.now();
//   List<Map<String, dynamic>> _medications = [];
//   double _medicationRate = 0.0;
//   String _feedbackMessage = "📊 복약 데이터를 불러오는 중...";
//   Map<String, List<Map<String, dynamic>>> _medicationsByTime = {};
//   Set<String> _expandedTimes = {};
//   Set<String> _loadingMedications = {}; // ✅ API 요청 중인 약 목록 (중복 클릭 방지)

//   @override
//   void initState() {
//     super.initState();
//     _fetchMedicationRecords();
//   }

//   void _openChatbot() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return FractionallySizedBox(heightFactor: 0.85, child: ChatBotScreen());
//       },
//     );
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     print("📌 날짜 선택됨: $selectedDay");

//     setState(() {
//       _selectedDay = selectedDay;
//     });
//     _fetchMedicationRecords();
//   }

//   // ✅ 복약 체크 업데이트 (API 요청 성공 후 UI 업데이트)
//   Future<void> _updateMedicationStatus(
//     String medName,
//     bool taken,
//     String tmDate,
//   ) async {
//     if (_loadingMedications.contains(medName)) return; // ✅ 중복 요청 방지

//     setState(() {
//       _loadingMedications.add(medName);
//     });

//     try {
//       await ApiService.updateMedicationStatus(medName, taken, tmDate);

//       // ✅ UI 즉시 업데이트
//       // setState(() {
//       //   _medicationsByTime.forEach((time, meds) {
//       //     for (var med in meds) {
//       //       if (med["name"] == medName) {
//       //         med["taken"] = taken;
//       //       }
//       //     }
//       //   });
//       // });

//       // ✅ API 반영 후 다시 로드 (데이터 갱신)
//       await _fetchMedicationRecords();
//     } catch (e) {
//       print("🚨 복약 상태 업데이트 실패: $e");
//     } finally {
//       setState(() {
//         _loadingMedications.remove(medName);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F5F5),
//       appBar: AppBar(
//         title: const Text(
//           "복약 기록",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildRoundedCalendar(),
//             const SizedBox(height: 16),
//             _buildMedicationList(),
//             const SizedBox(height: 55),
//             _buildMedicationFeedback(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openChatbot,
//         child: Icon(Icons.smart_toy, color: Colors.white),
//         backgroundColor: Color(0xFF648aed),
//       ),
//     );
//   }

//   Future<void> _scheduleMedicationNotifications() async {
//     _medicationsByTime.forEach((time, meds) {
//       meds.forEach((med) {
//         String medName = med["name"];
//         DateTime medTime = DateFormat("HH:mm:ss").parse(time); // ✅ 시간 변환
//         DateTime now = DateTime.now();

//         DateTime scheduleTime = DateTime(
//           now.year,
//           now.month,
//           now.day,
//           medTime.hour,
//           medTime.minute,
//         );

//         if (scheduleTime.isBefore(now)) {
//           scheduleTime = scheduleTime.add(
//             Duration(days: 1),
//           ); // ✅ 지나간 시간은 다음날로 변경
//         }

//         NotificationService.scheduleMedicationNotification(
//           med.hashCode,
//           medName,
//           scheduleTime,
//         );
//       });
//     });
//   }

//   Future<void> _fetchMedicationRecords() async {
//     try {
//       String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
//       List<Map<String, dynamic>> records =
//           await ApiService.getMedicationRecords(formattedDate);
//       print("📡 [디버깅] 가져온 복약 데이터: $records");

//       Map<String, List<Map<String, dynamic>>> groupedRecords = {};
//       for (var record in records) {
//         String time = record["time"];
//         if (!groupedRecords.containsKey(time)) {
//           groupedRecords[time] = [];
//         }
//         groupedRecords[time]!.add(record);
//       }

//       setState(() {
//         _medicationsByTime = groupedRecords;
//       });
//       await _scheduleMedicationNotifications();
//     } catch (e) {
//       print("🚨 복약 기록 불러오기 실패: $e");
//     }
//   }

//   Widget _buildMedicationList() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white, // ✅ 전체 카드 배경 (하얀색)
//         borderRadius: BorderRadius.circular(20), // ✅ 둥근 카드 UI
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05), // ✅ 연한 그림자 효과
//             blurRadius: 8,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children:
//             _medicationsByTime.entries.map((entry) {
//               String time = entry.key;
//               List<Map<String, dynamic>> medications = entry.value;

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       left: 8.0,
//                       bottom: 8,
//                       top: 12,
//                     ),
//                     child: Text(
//                       _convertTimeFormat(time),
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: CupertinoColors.black,
//                       ),
//                     ),
//                   ),
//                   Column(
//                     children:
//                         medications
//                             .map((med) => _buildMedicationItem(med))
//                             .toList(),
//                   ),
//                 ],
//               );
//             }).toList(),
//       ),
//     );
//   }

//   String _convertTimeFormat(String time) {
//     DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);
//     return DateFormat("a h:mm").format(parsedTime);
//   }

//   Widget _buildMedicationItem(Map<String, dynamic> med) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         vertical: 6,
//         horizontal: 16,
//       ), // ✅ 여백 조정
//       child: GestureDetector(
//         onTap: () async {
//           bool newValue = !(med["taken"] ?? false);
//           String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);

//           setState(() {
//             med["taken"] = newValue;
//           });

//           await _updateMedicationStatus(med["name"], newValue, formattedDate);
//         },
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 300), // ✅ 애니메이션 추가
//           width: double.infinity, // ✅ 가로 전체 사용
//           padding: EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12, // ✅ 내부 패딩 증가
//           ),
//           decoration: BoxDecoration(
//             color:
//                 med["taken"] ?? false
//                     ? Colors
//                         .indigoAccent
//                         .shade100 // ✅ 체크하면 색 변경
//                     : Color(0xFFF7F6F2), // ✅ 기본 배경색 (연한 크림색)
//             borderRadius: BorderRadius.circular(20), // ✅ 둥근 모서리 적용
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     med["taken"] ?? false
//                         ? Icons.check_circle
//                         : Icons.radio_button_unchecked, // ✅ 체크 아이콘
//                     color:
//                         med["taken"] ?? false
//                             ? Colors.blueAccent
//                             : Colors.grey.shade500,
//                     size: 20,
//                   ),
//                   SizedBox(width: 12), // ✅ 아이콘과 텍스트 간격 조정
//                   Text(
//                     med["name"],
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color:
//                           med["taken"] ?? false ? Colors.white : Colors.black87,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),

//               // ✅ 채팅 아이콘 (클릭하면 ChatBotScreen으로 이동)
//               GestureDetector(
//                 onTap: () {
//                   _openChatbotWithMedicineInfo(med["name"]);
//                 },
//                 child: Icon(
//                   Icons.chat_bubble_outline,
//                   color:
//                       med["taken"] ?? false
//                           ? Colors.white70
//                           : Colors.grey.shade600,
//                   size: 18,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openChatbotWithMedicineInfo(String medicineName) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return FractionallySizedBox(
//           heightFactor: 0.85,
//           child: ChatBotScreen(initialMessage: "이 $medicineName에 대한 정보를 알려줘."),
//         );
//       },
//     );
//   }

//   Widget _buildRoundedCalendar() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: TableCalendar(
//         firstDay: DateTime.utc(2024, 1, 1),
//         lastDay: DateTime.utc(2030, 12, 31),
//         focusedDay: _selectedDay,
//         selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
//         onDaySelected: (selectedDay, focusedDay) {
//           setState(() {
//             _selectedDay = selectedDay;
//           });
//           _fetchMedicationRecords(); // ✅ 새로운 날짜 데이터 가져오기
//         },

//         calendarFormat: CalendarFormat.week,
//         daysOfWeekVisible: false,
//         headerStyle: const HeaderStyle(
//           titleCentered: true,
//           formatButtonVisible: false,
//         ),
//         calendarStyle: CalendarStyle(
//           selectedDecoration: BoxDecoration(
//             color: Colors.blueAccent,
//             shape: BoxShape.circle,
//           ),
//           todayDecoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             shape: BoxShape.circle,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMedicationFeedback() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "오늘의 복약 피드백",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(Icons.incomplete_circle, color: Colors.blueAccent, size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 "복약률: $_medicationRate%",
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(
//             _feedbackMessage,
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
    _fetchMedicationRecords();
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

  String _convertTimeFormat(String time) {
    DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);
    String period = parsedTime.hour < 12 ? "오전" : "오후"; // ✅ AM → 오전, PM → 오후 적용
    int hour =
        parsedTime.hour % 12 == 0 ? 12 : parsedTime.hour % 12; // 12시간 형식 변환
    return "$period $hour:${parsedTime.minute.toString().padLeft(2, '0')}"; // ✅ 00 분 형식 유지
  }

  Widget _buildMedicationList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _medicationsByTime.entries.map((entry) {
            String time = entry.key;
            List<Map<String, dynamic>> medications = entry.value;
            bool isExpanded = _expandedTimes.contains(time);

            return Column(
              children: [
                // ✅ 시간 버튼 (테두리 제거, 배경색 추가)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedTimes.remove(time);
                      } else {
                        _expandedTimes.add(time);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100, // ✅ 배경색 추가
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // ✅ 아이콘과 텍스트 높이 맞춤
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.blueAccent,
                              size: 18,
                            ),
                            Text(
                              " ${_convertTimeFormat(time)}", // ✅ 공백 1칸 추가로 자연스럽게 붙임
                              style: TextStyle(
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

                // ✅ 해당 시간대의 약 리스트 (테두리 제거)
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
                              ), // ✅ 테두리 제거
                              leading: Icon(
                                med["taken"] ?? false
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color:
                                    med["taken"] ?? false
                                        ? Colors.blueAccent
                                        : Colors.grey.shade500,
                              ),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.medication,
                                    color: Colors.blueAccent,
                                    size: 18,
                                  ), // ✅ 알약 아이콘 추가
                                  SizedBox(width: 6), // ✅ 아이콘과 텍스트 사이 간격 조정
                                  Text(
                                    med["name"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          med["taken"] ?? false
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  _openChatbotWithMedicineInfo(med["name"]);
                                },
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color:
                                      med["taken"] ?? false
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                ),
                              ),
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
