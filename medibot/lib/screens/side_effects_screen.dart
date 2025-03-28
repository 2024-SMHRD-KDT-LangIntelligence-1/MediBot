import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideEffectRegisterScreen extends StatefulWidget {
  final String medName;

  const SideEffectRegisterScreen({super.key, required this.medName});

  @override
  State<SideEffectRegisterScreen> createState() =>
      _SideEffectRegisterScreenState();
}

class _SideEffectRegisterScreenState extends State<SideEffectRegisterScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _userNotes = [];

  @override
  void initState() {
    super.initState();
    _loadUserNotes();
  }

  void _loadUserNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'note_${widget.medName}';

    // ✅ 기존에 문자열로 저장된 경우 삭제
    if (prefs.containsKey(key) && prefs.get(key) is String) {
      await prefs.remove(key);
    }

    final notes = prefs.getStringList(key) ?? [];
    setState(() {
      _userNotes = notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "부작용 등록",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 약 이름
            Text(
              widget.medName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            const Text(
              "내가 겪은 부작용",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 6,
                decoration: const InputDecoration.collapsed(
                  hintText: "예: 복통, 어지러움, 피부 발진 등",
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_userNotes.isNotEmpty) ...[
              const Text(
                "기존에 작성한 메모",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _userNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(_userNotes[index]),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        final prefs = await SharedPreferences.getInstance();
                        final key = 'note_${widget.medName}';
                        final updated = List<String>.from(_userNotes)
                          ..removeAt(index);
                        await prefs.setStringList(key, updated);
                        setState(() {
                          _userNotes = updated;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _userNotes[index],
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final key = 'note_${widget.medName}';
                  final newNote = _controller.text.trim();
                  if (newNote.isEmpty) return;

                  final updatedNotes = [..._userNotes, newNote];
                  await prefs.setStringList(key, updatedNotes);
                  Navigator.pop(context, true); // ✅ 저장 후 결과 전달하며 뒤로가기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "저장하기",
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
