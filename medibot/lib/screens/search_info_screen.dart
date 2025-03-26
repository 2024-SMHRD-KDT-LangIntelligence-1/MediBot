import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchInfoScreen extends StatefulWidget {
  final String medName;

  const SearchInfoScreen({super.key, required this.medName});

  @override
  State<SearchInfoScreen> createState() => _SearchInfoScreenState();
}

class _SearchInfoScreenState extends State<SearchInfoScreen> {
  Future<DrugInfo?>? _drugInfoFuture;

  @override
  void initState() {
    super.initState();
    _drugInfoFuture = ApiService.fetchDrugDetailByName(widget.medName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "약물 상세 정보",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: FutureBuilder<DrugInfo?>(
        future: _drugInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("약물 정보를 불러올 수 없습니다."));
          }

          final drug = snapshot.data!;
          final sideEffects =
              (drug.sideEffectsFromRepo ?? '')
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⚠️ 부작용 주의 배지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "⚠️ 부작용 주의",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 약 이름
                Text(
                  widget.medName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 24),

                // 💊 부작용 섹션
                const Text(
                  "부작용",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      sideEffects.isEmpty
                          ? const Text("등록된 부작용 정보가 없습니다.")
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              sideEffects.length,
                              (index) => _SideEffectRow(
                                rank: "${index + 1}위",
                                text: sideEffects[index],
                              ),
                            ),
                          ),
                ),

                // 💊 상호작용 주의사항
                if (drug.mediInter != null &&
                    drug.mediInter!.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    "상호작용 주의사항",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      drug.mediInter!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        fontFamily: 'AppleSDGothicNeo',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SideEffectRow extends StatelessWidget {
  final String rank;
  final String text;

  const _SideEffectRow({required this.rank, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            rank,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'AppleSDGothicNeo',
            ),
          ),
        ],
      ),
    );
  }
}
