import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
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
  List<TimeOfDay> _selectedIntakeTimes = [];
  final TextEditingController _medicationController = TextEditingController();

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

  Future<void> _handleOCRAndSetData() async {
    print("📥 OCR 함수 진입"); // ✅ 이거 찍히는지 확인

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      print("📷 이미지 선택 취소됨");
      return;
    }
    print("📸 pickedFile: $pickedFile"); // 추가해봐

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    print("📄 inputImage created: ${pickedFile.path}");
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    print("🔍 textRecognizer created");
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    print("🧠 OCR 전체 인식 텍스트:\n${recognizedText.text}");

    final lines = recognizedText.text.split('\n');
    final koreanLine = lines.firstWhere(
      (line) => RegExp(r'[가-힣]').hasMatch(line),
      orElse: () => '',
    );

    print("🔍 추출된 한글 라인: $koreanLine");

    final cleaned = koreanLine.replaceAll(RegExp(r'[^가-힣0-9 ]'), '').trim();

    print("✅ 정제된 약 이름: $cleaned");

    if (cleaned.isNotEmpty) {
      setState(() {
        _medicationController.text = cleaned;
      });
    } else {
      print("❌ 약 이름 인식 실패");
    }

    if (recognizedText.text.contains("하루 1회") ||
        recognizedText.text.contains("매일 복용")) {
      print("📅 '하루 1회' 또는 '매일 복용' 문구 감지됨 → 2주치 날짜 자동 선택");

      final now = DateTime.now();
      final twoWeeks = List<DateTime>.generate(
        14,
        (i) => now.add(Duration(days: i)),
      );

      setState(() {
        _selectedDates = twoWeeks;
        _formattedDates =
            twoWeeks.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();
      });
    } else {
      print("📅 자동 날짜 선택 조건에 해당 없음");
    }
  }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🚨 사용자 ID를 찾을 수 없습니다.')));
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
        (route) => false,
      );
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
          onPressed: () => Navigator.pop(context),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    controller: _medicationController,
                    hintText: "약 이름 입력",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                  onPressed: () async {
                    print("📸 카메라 버튼 클릭됨"); // ← 이거 먼저 찍히는지 확인!
                    await _handleOCRAndSetData();
                  },
                ),
              ],
            ),
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
