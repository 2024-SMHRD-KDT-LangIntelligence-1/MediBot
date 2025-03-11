import 'package:flutter/material.dart';
import '../widgets/multi_date_picker.dart';
import '../widgets/intake_time_selector.dart';
import '../widgets/text_input_field.dart';
import '../widgets/register_button.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지

class MedicationRegistrationScreen extends StatefulWidget {
  const MedicationRegistrationScreen({super.key});

  @override
  _MedicationRegistrationScreenState createState() =>
      _MedicationRegistrationScreenState();
}

class _MedicationRegistrationScreenState
    extends State<MedicationRegistrationScreen> {
  List<DateTime> _selectedDates = []; // ✅ 선택한 날짜 저장 (초기 빈 리스트 설정)
  List<String> _formattedDates = []; // ✅ DB로 보낼 날짜 (yyyy-MM-dd 형식)
  List<Map<String, dynamic>> _selectedIntakeTimes = []; // ✅ 수정된 타입

  String _selectedIntakeTime = "식전";
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _pharmacyController = TextEditingController();

  // ✅ 날짜 업데이트 함수 (DB로 보낼 수 있도록 변환)
  void _updateSelectedDates(List<DateTime> dates) {
    setState(() {
      _selectedDates = List.from(dates); // ✅ Null Safety 보장
      _selectedDates.sort((a, b) => a.compareTo(b)); // ✅ 날짜 정렬 추가
      _formattedDates =
          _selectedDates
              .map((date) => DateFormat('yyyy-MM-dd').format(date))
              .toList();
      // print("✅ 저장된 날짜: $_formattedDates"); // 📌 선택한 날짜 확인 (디버깅용)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "복약 등록",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MultiDatePicker(
              selectedDates: _selectedDates, // ✅ 기존에 선택한 날짜를 유지
              onDatesSelected: _updateSelectedDates, // ✅ 날짜 업데이트 함수 연결
            ),
            const SizedBox(height: 16),

            IntakeTimeSelector(
              onTimesSelected: (times) {
                // ✅ 타입 일치
                setState(() {
                  _selectedIntakeTimes = times;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "약 이름 *",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextInputField(
              controller: _medicationController,
              hintText: "약 이름 입력",
            ),
            const SizedBox(height: 16),
            const Text(
              "약국명 *",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextInputField(
              controller: _pharmacyController,
              hintText: "약국 이름 입력",
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RegisterButton(
          onPressed: () {
            // ✅ 등록 버튼을 눌렀을 때 저장된 날짜를 출력 (DB 연동 시 활용)
            // print("📤 DB로 보낼 날짜 데이터: $_formattedDates");
          },
        ),
      ),
    );
  }
}
