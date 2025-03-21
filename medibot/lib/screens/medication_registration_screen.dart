import 'package:flutter/material.dart';
import 'package:medibot/widgets/bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/multi_date_picker.dart';
import '../widgets/intake_time_selector.dart';
import '../widgets/text_input_field.dart';
import '../widgets/register_button.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MedicationRegistrationScreen extends StatefulWidget {
  const MedicationRegistrationScreen({super.key});

  @override
  _MedicationRegistrationScreenState createState() =>
      _MedicationRegistrationScreenState();
}

class _MedicationRegistrationScreenState
    extends State<MedicationRegistrationScreen> {
  List<DateTime> _selectedDates = [];
  List<String> _formattedDates = [];
  List<TimeOfDay> _selectedIntakeTimes = []; // ✅ TimeOfDay 리스트로 변경

  final TextEditingController _medicationController = TextEditingController();

  // 날짜 선택 후 업데이트
  void _updateSelectedDates(List<DateTime> dates) {
    setState(() {
      _selectedDates = List.from(dates);
      _selectedDates.sort((a, b) => a.compareTo(b));
      _formattedDates =
          _selectedDates
              .map((date) => DateFormat('yyyy-MM-dd').format(date))
              .toList();
    });
  }

  // 복약 일정 등록 API 호출
  void _validateAndSubmit() async {
    if (_formattedDates.isEmpty ||
        _selectedIntakeTimes.isEmpty ||
        _medicationController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 필수 항목을 입력해주세요.')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🚨 사용자 ID를 찾을 수 없습니다. 로그인을 다시 해주세요.')),
      );
      return;
    }

    try {
      for (String date in _formattedDates) {
        for (TimeOfDay time in _selectedIntakeTimes) {
          final String tmTime =
              "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

          await ApiService.createSchedule(
            userId: userId,
            mediName: _medicationController.text,
            tmDate: date,
            tmTime: tmTime,
          );
        }
      }
      Navigator.pop(context);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
        (route) => false,
      );
      // Navigator.pop(context);
    } catch (e) {
      print("🚨 오류 발생: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('🚨 등록 실패: $e')));
    }
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
              selectedDates: _selectedDates,
              onDatesSelected: _updateSelectedDates,
            ),
            const SizedBox(height: 16),

            IntakeTimeSelector(
              onTimesSelected: (times) {
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
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RegisterButton(onPressed: _validateAndSubmit),
      ),
    );
  }
}
