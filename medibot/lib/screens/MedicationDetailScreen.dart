import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MedicationEditScreen.dart';

class MedicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> medication;

  const MedicationDetailScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "약물카드 상세보기",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showActionSheet(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5FA),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMedicationCard(),
            const SizedBox(height: 24),
            _buildSideEffects(),
            const SizedBox(height: 24),
            CupertinoButton(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
              onPressed: () {},
              child: const Text(
                "내 부작용 등록하기",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          _buildWarningTag(),
          const SizedBox(height: 12),

          // 약 이름
          Text(
            medication["name"] ?? "약 정보 없음",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 12),
          Container(
            width: double.infinity, // 부모 너비 최대로 확장
            constraints: const BoxConstraints(
              minHeight: 40,
            ), // 최소 높이 설정 (여백 확보)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${medication["startDate"] ?? "-"} ~ ${medication["endDate"] ?? "-"}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2, // ✅ 최대 2줄까지 허용
                  overflow: TextOverflow.ellipsis, // 너무 길면 "..." 처리
                ),
                const SizedBox(height: 4), // 간격 추가
                Text(
                  medication["hospital"] ?? "처방 병원 없음",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2, // ✅ 최대 2줄까지 허용
                  overflow: TextOverflow.ellipsis, // 너무 길면 "..." 처리
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _buildIntakeTimes(),
        ],
      ),
    );
  }

  Widget _buildWarningTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text(
            "부작용 주의",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeTimes() {
    List<Map<String, dynamic>> intakeTimes =
        (medication["intakeTimes"] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return Row(
      children:
          intakeTimes.map((time) {
            return _buildTag("${time["type"]} | ${time["time"]}");
          }).toList(),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSideEffects() {
    List<String> effects = ["고지혈증", "여성형 유방", "가려움"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "20대, 남성에서 발생할 수 있는 부작용 순위",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children:
              effects.asMap().entries.map((entry) {
                int index = entry.key + 1;
                return _buildSideEffect("${index}위", entry.value);
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSideEffect(String rank, String effect) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            rank,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            effect,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: Text("옵션 선택"),
            message: Text("이 약에 대해 원하는 작업을 선택하세요."),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder:
                          (context) =>
                              MedicationEditScreen(medication: medication),
                    ),
                  );
                },
                child: Text("수정", style: TextStyle(color: Colors.blueAccent)),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                isDestructiveAction: true,
                child: Text("삭제"),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(color: Colors.indigoAccent)),
            ),
          ),
    );
  }
}
