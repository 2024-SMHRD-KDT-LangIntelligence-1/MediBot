import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
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
import 'package:string_similarity/string_similarity.dart'; // pubspec.yaml에 추가 필요

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

  Future<String?> _handleOCRAndSetData() async {
    print("📥 OCR 함수 진입 (Naver Cloud OCR)");

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      print("📷 이미지 선택 취소됨");
      return null;
    }

    final bytes = await File(pickedFile.path).readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse(
      "https://8mx810cn8e.apigw.ntruss.com/custom/v1/39498/3ab994bd8699d77e4b09ed85f26e9d71a204c2a32f4006cc2481c5b1549b2762/general",
    );
    final headers = {
      "X-OCR-SECRET": "bmNsTklGSFFOWnlqSVNKZG9KeE5CTWRId3R3Z0NDeUE=",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "version": "V2",
      "requestId": "medireg_ocr",
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

        // OCR 전체 텍스트 연결
        final allText = fields.map((f) => f['inferText'].toString()).join(' ');
        print("🧠 OCR 전체 텍스트: $allText");

        // 단어 단위 나누기
        final words =
            allText
                .split(RegExp(r'\s+'))
                .map((w) => w.trim())
                .where((w) => w.isNotEmpty)
                .toList();

        // 필터링된 후보 단어
        final candidates =
            words.where((word) {
              return word.contains(RegExp(r'[가-힣]')) &&
                  word.length >= 2 &&
                  word.length <= 30 &&
                  !word.contains(
                    RegExp(r'(제조자|수입자|서울특별시|의약품안전나라|https|품목허가사항|식약처|용산구|판매)'),
                  );
            }).toList();

        print("🔍 후보 단어: $candidates");

        String? matchedDrug;

        for (final word in candidates) {
          final matches = await ApiService.searchDrugByName(word);
          print("🟢 검색 결과 리스트: ${matches.length}개");
          print("📡 응답 본문: $matches");

          if (matches.isNotEmpty) {
            final keyword =
                word.replaceAll(RegExp(r'[^가-힣a-zA-Z0-9]'), '').toLowerCase();

            final banList = [
              '우먼스',
              '어린이',
              '콜드',
              '에스',
              '8시간',
              '서방',
              '현탁액',
              '코드',
              '액',
              '이알',
              '시럽',
            ];

            List<String> smartFilter(List<String> list) {
              return list.where((item) {
                final lower = item.toLowerCase();
                final cleaned = lower.replaceAll(
                  RegExp(r'(정|밀리그램|500|160|250|정제|서방정)'),
                  '',
                );
                return cleaned.contains(keyword) &&
                    !banList.any((ban) => lower.contains(ban));
              }).toList();
            }

            // 1순위: 스마트 필터로 남은 약
            final preferred = smartFilter(matches);
            if (preferred.isNotEmpty) {
              preferred.sort((a, b) => a.length.compareTo(b.length));
              matchedDrug = preferred.first;
              print("✅ 스마트 필터링 대표 약: $matchedDrug");
            } else {
              // fallback: keyword 포함한 애들 중 제일 짧은 거
              final fallback =
                  matches
                      .where((m) => m.toLowerCase().contains(keyword))
                      .toList();
              if (fallback.isNotEmpty) {
                fallback.sort((a, b) => a.length.compareTo(b.length));
                matchedDrug = fallback.first;
                print("⚠️ fallback 사용된 약: $matchedDrug");
              } else {
                print("💀 최종 fallback: 아무거나 선택");
                matches.sort((a, b) => a.length.compareTo(b.length));
                matchedDrug = matches.first;
              }
            }

            break;
          }
        }
        print("🔍 백엔드 매칭 결과: $matchedDrug");

        if (matchedDrug != null && matchedDrug.isNotEmpty) {
          print("✅ 최종 약 이름: $matchedDrug");
          setState(() {
            _medicationController.text = matchedDrug!;
          });
        } else {
          print("❌ 약 이름 인식 실패");
        }

        // 날짜 자동 선택
        if (allText.contains("하루 1회") || allText.contains("매일 복용")) {
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

          print("📅 '하루 1회' 또는 '매일 복용' 감지됨 → 2주 날짜 자동 선택 완료");
        } else {
          print("📅 날짜 자동 선택 조건 해당 없음");
        }
      } else {
        print("❌ 네이버 OCR API 실패: ${response.body}");
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
    }

    return null;
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
              const SizedBox(height: 20),

              Center(
                child: Text(
                  "※ 본 앱은 일반적인 건강 정보를 제공하며,\n"
                  "전문적인 의학적 진단이나 치료를 대체하지 않습니다.\n"
                  "정확한 의학적 판단을 위해 반드시 의사와 상담하시기 바랍니다.\n\n"
                  "출처: 식품의약품안전처 의약품개요정보 (nedrug.mfds.go.kr)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
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
