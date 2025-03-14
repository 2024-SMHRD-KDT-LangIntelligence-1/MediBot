import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'MedicationDetailScreen.dart';
import 'ChatBotScreen.dart';

class MedicationRecordScreen extends StatefulWidget {
  const MedicationRecordScreen({super.key});

  @override
  _MedicationRecordScreenState createState() => _MedicationRecordScreenState();
}

class _MedicationRecordScreenState extends State<MedicationRecordScreen> {
  DateTime _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _medications = [
    {"name": "○○", "time": "08:00 AM", "type": "식전", "taken": false},
    {"name": "고지혈약", "time": "01:00 PM", "type": "식후", "taken": false},
    {"name": "혈압약", "time": "07:00 PM", "type": "식후", "taken": false},
  ];

  double _medicationRate = 90.0; // 복약률 예제 데이터
  String _feedbackMessage = "👍 오늘 모든 약을 잘 챙겨 먹었어요! 🎉";

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 🟢 화면을 최대한 크게 확장
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85, // 🟢 화면의 85% 차지 (더 크게 설정)
          child: ChatBotScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // 새로운 배경색 적용
      appBar: AppBar(
        title: const Text(
          "복약 기록",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(CupertinoIcons.back, color: Colors.black),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRoundedCalendar(),
            const SizedBox(height: 16),
            _buildMedicationList(),
            const SizedBox(height: 55),
            _buildMedicationFeedback(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openChatbot,
        child: Icon(Icons.smart_toy, color: Colors.white),
        backgroundColor: Color(0xFF648aed),
      ),
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

  Widget _buildMedicationList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Column(
          children:
              _medications.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> med = entry.value;
                return _buildMedicationItem(med, index); // 타입 변환 제거
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicationFeedback() {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "오늘의 복약 피드백",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.incomplete_circle, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                "복약률: $_medicationRate%",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _feedbackMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> med, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MedicationDetailScreen(
                  medication: {
                    ...med,
                    "intakeTimes": [
                      {"type": med["type"], "time": med["time"]},
                    ],
                  },
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
        child: Row(
          children: [
            Icon(Icons.medication, color: Colors.blueAccent, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med["name"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${med["time"]} | ${med["type"]}",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Spacer(),
            Checkbox(
              value: med["taken"] ?? false,
              onChanged: (bool? newValue) {
                setState(() {
                  _medications[index]["taken"] = newValue;
                });
              },
            ),
            // const SizedBox(width: 8),
            // Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
