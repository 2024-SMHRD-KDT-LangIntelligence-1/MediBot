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

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.time;
    _initialTime = widget.time; // ✅ 초기 시간 따로 저장

    _fetchDateRange();
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 맨 위: 약 이름 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                widget.medName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // ✅ 복용일자 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "복용일자",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _dateRange,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ 복약 시간 선택 가능하도록 변경 (iOS 스타일)
            const Text(
              "복약 시간",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime, // ✅ iOS 스타일 시간 선택 다이얼로그 실행
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ 확인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedTime != _initialTime) {
                    await _updateMedicationTime(_selectedTime); // ✅ 시간 업데이트
                  }
                  Navigator.pop(context); // ✅ 완료 후 이전 화면으로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "확인",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
