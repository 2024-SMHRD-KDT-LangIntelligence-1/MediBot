import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class MedicationDetailScreen extends StatefulWidget {
  final String medName;
  final String time;

  const MedicationDetailScreen({
    super.key,
    required this.medName,
    required this.time,
  });

  @override
  _MedicationDetailScreenState createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  String _dateRange = "조회 중...";
  late String _selectedTime;
  late String _initialTime; // ✅ 초기 시간 저장용 변수
  String? _selectedMessage;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.time;
    _initialTime = widget.time; // ✅ 초기 시간 따로 저장
    _selectedMessage = (_messages..shuffle()).first;

    _fetchDateRange();
  }

  final List<String> _messages = [
    "이 약은 제 시간에 복용하는 것이 중요해요.",
    "복용 시간, 놓치지 마세요 ⏰",
    "건강은 습관에서 시작돼요.",
    "오늘도 건강한 하루 되세요 ☀️",
    "약을 규칙적으로 먹으면 더 빨리 회복돼요!",
    "당신의 건강을 응원합니다 💪",
    "한 알의 약, 큰 건강 🌿",
    "시간 맞춰 복용하는 습관, 잊지 마세요.",
    "오늘도 꼼꼼하게 복약 완료!",
    "약 먹는 것도 자기관리의 시작이에요 🧘‍♀️",
    "잘하고 있어요! 지금처럼만 계속 💙",
    "잠깐! 약 드셨나요? 😌",
    "당신의 몸도 당신의 노력을 기억해요 🙏",
    "꾸준함은 최고의 치료제입니다.",
    "작은 습관이 큰 변화를 만듭니다 🌱",
    "지금의 습관이 내일의 건강을 만듭니다.",
    "하루 한 번, 당신을 위한 케어 💊",
    "오늘도 잊지 않고 챙기셨네요! 👍",
    "시간은 약, 그리고 약도 시간입니다.",
    "내 몸을 위한 약속, 지금 지켜볼까요?",
    "천천히, 하지만 꾸준히가 중요해요.",
    "조금씩, 하지만 매일같이 ✨",
    "잊지 마세요, 당신은 소중한 사람이에요 ❤️",
    "건강은 내가 챙기는 최고의 자산이에요.",
    "당신은 이미 잘하고 있어요 👏",
    "오늘도 나 자신을 위한 작은 실천 💖",
    "건강은 꾸준함 속에 자랍니다.",
    "이 약은 당신을 위한 응원이에요 🙌",
    "하루하루의 복약이 미래를 바꿔요.",
    "스스로를 아끼는 가장 좋은 방법입니다.",
    "시간 지켜서 먹는 습관, 건강 지키는 첫 걸음!",
  ];

  /// ✅ 복용일자 조회
  Future<void> _fetchDateRange() async {
    try {
      final result = await ApiService.getMedicationDateRange(
        widget.medName,
        widget.time,
      );
      setState(() {
        _dateRange = "${result['startDate']} ~ ${result['endDate']}";
      });
    } catch (e) {
      setState(() {
        _dateRange = "조회 실패";
      });
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String mediName,
    String tmTime,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text("삭제 확인"),
          content: const Text("정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다."),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                "취소",
                style: TextStyle(color: CupertinoColors.activeBlue),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(); // ❌ 팝업 닫기
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, // 🔥 빨간색 강조
              child: const Text("삭제"),
              onPressed: () async {
                Navigator.of(ctx).pop(); // ✅ 팝업 닫기
                try {
                  await ApiService.deleteMedication(mediName, tmTime);

                  // ✅ 현재 화면을 닫고 이전 화면으로 돌아가기
                  Navigator.of(context).pop();

                  // ✅ 삭제 성공 메시지 표시
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text("✅ 복약 일정이 삭제되었습니다.")),
                  // );
                } catch (e) {
                  // 🚨 삭제 실패 시 오류 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("🚨 삭제 실패: ${e.toString()}")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// ✅ 복약 시간 수정 (사용자가 선택)
  Future<void> _updateMedicationTime(String newTime) async {
    try {
      await ApiService.updateMedicationTime(
        widget.medName,
        _initialTime,
        newTime,
      );
    } catch (e) {
      print("🚨 복약 시간 수정 실패: $e");
    }
  }

  /// ✅ iOS 스타일 시간 선택 다이얼로그
  void _pickTime() {
    DateTime now = DateTime.now();
    DateTime initialTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(_selectedTime.split(":")[0]),
      int.parse(_selectedTime.split(":")[1]),
    );

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "완료",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedTime =
                          "${newDate.hour.toString().padLeft(2, '0')}:${newDate.minute.toString().padLeft(2, '0')}:00";
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "복약 일정 수정",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed:
                () => _showDeleteConfirmation(
                  context,
                  widget.medName,
                  widget.time,
                ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white, // 밝은 배경색
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.medName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedMessage!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 복용일자
            const Text(
              "복용일자",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_dateRange, style: const TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 24),
            const Text(
              "복약 시간",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Text(_selectedTime, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const Text(
                  "확인",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: () async {
                  if (_selectedTime != _initialTime) {
                    await _updateMedicationTime(_selectedTime);
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
