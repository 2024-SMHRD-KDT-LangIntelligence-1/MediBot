import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon; // ✅ 아이콘 옵션 추가
  final bool obscureText; // ✅ 비밀번호 입력용 여부 추가 (기본값 false)

  const TextInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false, // ✅ 기본값 false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // ✅ 위아래 여백 추가
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // ✅ 더 둥글게 변경
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText, // ✅ 비밀번호 입력 여부 적용
        style: const TextStyle(fontSize: 16), // ✅ 텍스트 스타일 조정
        decoration: InputDecoration(
          prefixIcon:
              prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.blueAccent) // ✅ 아이콘 적용
                  : null,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ), // ✅ 애플스럽게 얇고 은은한 힌트 스타일
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ), // ✅ 내부 여백 추가
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), // ✅ 둥근 스타일 적용
            borderSide: BorderSide.none, // ✅ 테두리 없애고 부드럽게
          ),
        ),
      ),
    );
  }
}
