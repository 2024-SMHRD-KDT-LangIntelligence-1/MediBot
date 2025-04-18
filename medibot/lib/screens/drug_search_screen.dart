import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/api_service.dart';
import 'search_info_screen.dart';

class DrugSearchScreen extends StatefulWidget {
  const DrugSearchScreen({super.key});

  @override
  State<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("약 검색"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // ← 추가
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "약 이름을 검색하세요",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TypeAheadField<String>(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchInfoScreen(medName: suggestion),
                  ),
                );
              },
              builder: (context, controller, focusNode) {
                controller.text = _controller.text;
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
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      _controller.text = value;
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "검색 결과는 선택 후 상세보기로 연결됩니다.",
              style: TextStyle(color: Colors.indigoAccent),
            ),
            const SizedBox(height: 20),

            Center(
              child: Text(
                "※ 본 앱은 일반적인 건강 정보를 제공하며,\n"
                "전문적인 의학적 진단이나 치료를 대체하지 않습니다.\n"
                "정확한 의학적 판단을 위해 반드시 의사와 상담하시기 바랍니다.\n\n"
                "출처: 식품의약품안전처 의약품개요정보 (nedrug.mfds.go.kr)",
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
