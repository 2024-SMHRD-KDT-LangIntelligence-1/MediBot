import 'dart:io';
import 'dart:convert';
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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

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
    print("📥 OCR 함수 진입 (Naver Cloud OCR)");

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      print("📷 이미지 선택 취소됨");
      return;
    }
    print("📸 pickedFile: ${pickedFile.path}");

    final bytes = await File(pickedFile.path).readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse(
      "https://8mx810cn8e.apigw.ntruss.com/custom/v1/39498/3ab994bd8699d77e4b09ed85f26e9d71a204c2a32f4006cc2481c5b1549b2762/general",
    );
    final headers = {
      "X-OCR-SECRET": "bmNsTklGSFFOWnlqSVNKZG9KeE5CTWRId3R3Z0NDeUE=",
      // "X-NCP-APIGW-API-KEY-ID":
      //     "ncp_iam_BPASKR2wlPWfDF43vUz5", // <-- 여기에 본인의 클라이언트 ID 입력
      // "X-NCP-APIGW-API-KEY":
      //     "ncp_iam_BPKSKRS6jvEwzyasM6bdGJwiM65o2tVMkB", // <-- 여기에 본인의 클라이언트 SECRET 입력
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "version": "V2",
      "requestId": "sample_id",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "images": [
        {"format": "jpg", "name": "ocr_image", "data": base64Image},
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fields = data['images'][0]['fields'] as List<dynamic>;
        final allText = fields.map((f) => f['inferText'].toString()).join(' ');
        print("🧠 OCR 전체 인식 텍스트 (Naver): $allText");

        final koreanLine = allText
            .split(' ')
            .firstWhere(
              (word) => RegExp(r'[가-힣]').hasMatch(word),
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

        if (allText.contains("하루 1회") || allText.contains("매일 복용")) {
          print("📅 '하루 1회' 또는 '매일 복용' 문구 감지됨 → 2주치 날짜 자동 선택");

          final now = DateTime.now();
          final twoWeeks = List<DateTime>.generate(
            14,
            (i) => now.add(Duration(days: i)),
          );

          setState(() {
            _selectedDates = twoWeeks;
            _formattedDates =
                twoWeeks
                    .map((d) => DateFormat('yyyy-MM-dd').format(d))
                    .toList();
          });
        } else {
          print("📅 자동 날짜 선택 조건에 해당 없음");
        }
      } else {
        print("❌ 네이버 OCR API 실패: ${response.body}");
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                    child: TypeAheadField<String>(
                      suggestionsCallback: (pattern) async {
                        if (pattern.trim().isEmpty) return [];
                        return await ApiService.searchDrugByName(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.medication_outlined,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                suggestion,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onSelected: (suggestion) {
                        _medicationController.text = suggestion;
                        setState(() {});
                      },
                      builder: (context, controller, focusNode) {
                        controller.text = _medicationController.text;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              hintText: "약 이름 검색",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              _medicationController.text = value;
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () async {
                      print("📸 카메라 버튼 클릭됨");
                      await _handleOCRAndSetData();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RegisterButton(onPressed: _validateAndSubmit),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
