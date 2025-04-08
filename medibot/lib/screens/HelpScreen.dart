import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '도움말',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 인트로 카드
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.auto_awesome, color: Colors.indigoAccent, size: 40),
                SizedBox(height: 12),
                Text(
                  "MediBot은 AI 챗봇과 함께 복약을 쉽고 꾸준하게 실천할 수 있도록 도와주는 스마트 복약 파트너입니다.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          _buildSectionTitle("앱 소개"),
          _buildSectionBody(
            "이 앱은 사용자의 복약 스케줄을 관리할 뿐만 아니라, AI 기반 챗봇을 통해 복약 관련 질문에 응답하고, 복약 패턴을 분석해 맞춤형 피드백을 제공하는 스마트 복약 도우미입니다.",
          ),

          _buildSectionTitle("주요 기능"),
          _buildBullet("오늘 복약할 약 확인 및 체크 기능"),
          _buildBullet("복약 체크 시간에 따라 정상 복용 여부 판별"),
          _buildBullet("요일별 통계 제공 및 누락 시간 분석"),
          _buildBullet("AI 챗봇을 통한 복약 관련 질문 응답"),
          _buildBullet("사용자의 복약 패턴 분석 기반 피드백 제공"),

          _buildSectionTitle("자주 묻는 질문"),
          _buildQnA(
            "Q. 복약 체크는 어떻게 하나요?",
            "오늘 날짜를 선택하고 약 이름 오른쪽 체크 버튼을 누르면 복약이 기록됩니다.",
          ),
          _buildQnA(
            "Q. 다른 날짜의 복약은 체크할 수 없나요?",
            "네, 오늘 날짜만 복약 체크가 가능하며, 다른 날짜는 복약 기록만 조회할 수 있어요.",
          ),
          _buildQnA(
            "Q. 로그인은 꼭 해야 하나요?",
            "네, 모든 기능을 사용하기 위해서는 로그인 또는 회원가입이 필요합니다.",
          ),

          const SizedBox(height: 30),
          Center(
            child: Text(
              "더 궁금한 점이 있으신가요?",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: CupertinoButton(
              color: Colors.indigoAccent,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              onPressed: () {
                // TODO: 문의 기능 연결 예정
              },
              child: const Text("문의하기", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "이 앱은 일반적인 건강 정보를 제공하며, 전문적인 의학적 진단이나 치료를 대체하지 않습니다. "
            "정확한 의학적 판단을 위해 의사와 상담하시기 바랍니다.",
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  static Widget _buildSectionBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
          height: 1.6,
        ),
      ),
    );
  }

  static Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Colors.indigoAccent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildQnA(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(color: Colors.grey.shade800, height: 1.5),
          ),
        ],
      ),
    );
  }
}
