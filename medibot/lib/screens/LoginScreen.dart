import 'package:flutter/material.dart';
import 'signup.dart'; // 회원가입 페이지 추가
import 'package:medibot/screens/signup.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInput);
    _passwordController.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isLoginEnabled =
          _emailController.text.isNotEmpty &&
          _passwordController.text.length >= 8;
    });
  }

  void _login() {
    // 로그인 로직 (API 연동)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("로그인 성공!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 버튼
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "로그인",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "로그인하고\nMediBot 100% 이용하기",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30),

            // 🟢 이메일 입력 필드
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "아이디",
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),

            // 🔵 비밀번호 입력 필드
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "비밀번호 (영문+숫자, 8자리 이상)",
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),

            // 🔴 로그인 버튼 (입력 검증 후 활성화)
            ElevatedButton(
              onPressed: _isLoginEnabled ? _login : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isLoginEnabled
                        ? Colors.indigoAccent
                        : Colors.grey.shade300, // 비활성화 시 회색
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "로그인",
                style: TextStyle(
                  fontSize: 16,
                  color: _isLoginEnabled ? Colors.white : Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 20),

            // ⚫ 비밀번호 재설정 & 회원가입 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("비밀번호 재설정 페이지 이동")));
                  },
                  child: Text(
                    "비밀번호 재설정",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Text(" | ", style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignUpScreen()),
                      ),
                  child: Text("회원가입", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
