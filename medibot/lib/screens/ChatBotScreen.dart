import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  List<Map<String, dynamic>> messages = []; // 🔹 동적 메시지 리스트
  TextEditingController _controller = TextEditingController();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return; // 🔹 빈 입력 방지

    // 🔹 사용자 메시지 추가
    setState(() {
      messages.add({'text': text, 'isUser': true, 'time': DateTime.now()});
    });

    _controller.clear(); // 🔹 입력창 초기화

    try {
      // 🔹 Flask 서버에 메시지 전송 (URL 수정)
      var response = await http.post(
        Uri.parse('http://127.0.0.1:5000/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // 🔹 챗봇 응답 추가
        setState(() {
          messages.add({
            'text': data['response'], // 🔥 Flask 서버에서 받은 응답
            'isUser': false,
            'time': DateTime.now(),
          });
        });
      } else {
        print("서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      print("서버 연결 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7EBF0), // 연한 블루-그레이 배경
      body: Column(
        children: [
          // 🔹 경계 없는 상단 바
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF847AD1), Color(0xFF7AA4E5)], // 중간톤 보라-파랑
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "MediBot",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.bolt, color: Colors.yellowAccent, size: 18),
                      ],
                    ),
                    Text(
                      "보통 몇 분 내에 응답합니다.",
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.white, size: 22),
                  onPressed: () {
                    print("설정 클릭");
                  },
                ),
              ],
            ),
          ),

          // 🔹 오늘 날짜
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "오늘",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),

          // 🔹 메시지 영역 (동적으로 업데이트)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var msg =
                      messages[messages.length - 1 - index]; // 🔹 최신 메시지가 아래로
                  return ChatBubble(
                    text: msg['text'],
                    isUser: msg['isUser'],
                    avatar: msg['isUser'] ? Icons.person : Icons.smart_toy,
                    name: msg['isUser'] ? "사용자" : "MediBot",
                    time: msg['time'],
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 12), // 🔹 마지막 대화창과 입력창 사이 간격 추가
          // 🔹 입력창 (화면 맨 아래 고정)
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 12),
            decoration: BoxDecoration(color: Color(0xFFE7EBF0)),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _controller,
                      placeholder: "메시지를 입력하세요...",
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => sendMessage(_controller.text),
                    child: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      radius: 24,
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 메시지 말풍선 + 프로필 아이콘 + 이름 + 시간
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final IconData avatar;
  final String name;
  final DateTime time;

  ChatBubble({
    required this.text,
    required this.isUser,
    required this.avatar,
    required this.name,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('hh:mm a').format(time);

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: Icon(avatar, color: Colors.black54),
              ),
            if (!isUser) SizedBox(width: 8),

            Text(
              "$name · $formattedTime",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),

            if (isUser) SizedBox(width: 8),
            if (isUser)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueAccent.shade100,
                child: Icon(avatar, color: Colors.white),
              ),
          ],
        ),
        SizedBox(height: 4),

        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blueAccent : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isUser ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
