import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '/services/StorageManager.dart';
import 'package:medibot/services/api_service.dart';
import 'LoginScreen.dart';

const Color kBackgroundColor = Colors.white;
const Color kTextFieldFillColor = Color(0xFFF2F2F7);
const Color kPrimaryColor = CupertinoColors.activeBlue;
const Color kTextColor = CupertinoColors.darkBackgroundGray;
const double kBorderRadius = 14;

InputDecoration _inputDecoration(String hintText) => InputDecoration(
  hintText: hintText,
  filled: true,
  fillColor: kTextFieldFillColor,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kBorderRadius),
    borderSide: BorderSide.none,
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
);

ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
  backgroundColor: kPrimaryColor,
  foregroundColor: Colors.white,
  padding: EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kBorderRadius),
  ),
);

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _ageController =
      TextEditingController(); // ✅ 나이 입력 필드 추가
  void _selectBirthDate(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height: 250,
            color: Colors.white,
            child: Column(
              children: [
                // 확인 버튼
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "취소",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "확인",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date, // ✅ 날짜 선택 모드
                    initialDateTime: DateTime(2000, 1, 1), // 기본값
                    minimumDate: DateTime(1900, 1, 1), // 최소 선택 가능 날짜
                    maximumDate: DateTime.now(), // 오늘까지 가능
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedBirthDate = newDate;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  bool _isIdChecked = false;
  String? _passwordError;
  String _gender = "M"; // 기본 성별
  String _wakeUpTime = "07:00:00"; // 기본 기상 시간
  String _sleepTime = "23:00:00"; // 기본 취침 시간
  DateTime? _selectedBirthDate; // ✅ 생년월일 저장 변수

  // /// ✅ 이메일 중복 확인
  void _checkIdDuplicate() async {
    try {
      bool isDuplicate = await ApiService.checkEmailDuplicate(
        _idController.text,
      );
      setState(() {
        _isIdChecked = !isDuplicate;
      });

      showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: Text("알림"),
              content: Text(
                isDuplicate ? "이미 사용 중인 이메일입니다." : "사용 가능한 이메일입니다!",
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "확인",
                    style: TextStyle(color: Colors.indigoAccent),
                  ),
                ),
              ],
            ),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: Text("오류"),
              content: Text("이메일 중복 확인 실패: $e"),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "확인",
                    style: TextStyle(color: Colors.indigoAccent),
                  ),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Text(
              "회원가입",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            SizedBox(height: 24),
            _buildTextField(_nameController, "이름"),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _idController,
                    "아이디 (이메일)",
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _checkIdDuplicate();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("중복확인"),
                ),
              ],
            ),
            _buildTextField(_passwordController, "비밀번호", isPassword: true),
            _buildTextField(
              _confirmPasswordController,
              "비밀번호 확인",
              isPassword: true,
            ),
            if (_passwordError != null)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  _passwordError!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            GestureDetector(
              onTap: () => _selectBirthDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedBirthDate != null
                          ? "${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}"
                          : "생년월일 선택", // 기본값
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedBirthDate = null;
                        });
                      },
                      child: Text(
                        "건너뛰기",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isIdChecked
                        ? () {
                          StorageManager().saveUserInfo(
                            _nameController.text,
                            _idController.text,
                            _passwordController.text,
                            _selectedBirthDate != null
                                ? "${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}"
                                : null, // null 전달
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => IntroScreen()),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: Text(
                  "다음",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: _inputDecoration(hintText),
        style: TextStyle(fontSize: 16, color: kTextColor),
      ),
    );
  }
}

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF4FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "현재 드시고 계신 약에 대한 조사입니다.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GenderSelectionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "시작하기",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenderSelectionScreen extends StatefulWidget {
  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: 0.2, // 첫 화면이니 진행도의 20% 정도만 표시
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
            ),
            SizedBox(height: 20),
            Text(
              "성별",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "같은 성별과 연령대가 많이 검사하는 항목을 설정합니다",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_genderButton("남성"), _genderButton("여성")],
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedGender = null;
                });
                StorageManager().saveGender(null);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SleepScheduleScreen()),
                );
              },
              child: Text("건너뛰기", style: TextStyle(color: Colors.blueAccent)),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedGender != null
                        ? () {
                          // 성별 저장
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SleepScheduleScreen(),
                            ),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedGender != null
                          ? Colors.blueAccent
                          : Colors.grey[300],
                  foregroundColor:
                      selectedGender != null ? Colors.white : Colors.grey,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "다음",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderButton(String gender) {
    bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });

        StorageManager().saveGender(gender);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          gender,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class MedicationScheduleScreen extends StatefulWidget {
  @override
  _MedicationScheduleScreenState createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  List<Map<String, dynamic>> _medicationTimes = [
    {'period': '오전', 'hour': 9, 'minute': 0, 'icon': Icons.wb_sunny},
    {'period': '오후', 'hour': 12, 'minute': 0, 'icon': Icons.nights_stay},
    {'period': '오후', 'hour': 18, 'minute': 0, 'icon': Icons.nights_stay},
  ];

  void _addMedicationTime() {
    setState(() {
      _medicationTimes.add({
        'period': '오전',
        'hour': 8,
        'minute': 0,
        'icon': Icons.wb_sunny,
      });
    });
    StorageManager().saveMedicationTime(_medicationTimes);
  }

  void _removeMedicationTime(int index) {
    setState(() {
      _medicationTimes.removeAt(index);
    });
    StorageManager().saveMedicationTime(_medicationTimes);
  }

  void _showCupertinoTimePicker(int index) {
    DateTime initialTime = DateTime(
      2025,
      1,
      1,
      _medicationTimes[index]['hour'],
      _medicationTimes[index]['minute'],
    );

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              // 확인 버튼 추가
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "취소",
                        style: TextStyle(fontSize: 18, color: Colors.redAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                        StorageManager().saveMedicationTime(_medicationTimes);
                      },
                      child: Text(
                        "확인",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      _medicationTimes[index]['hour'] = newTime.hour;
                      _medicationTimes[index]['minute'] = newTime.minute;
                      _medicationTimes[index]['period'] =
                          newTime.hour < 12 ? '오전' : '오후';
                      _medicationTimes[index]['icon'] =
                          newTime.hour < 12
                              ? Icons.wb_sunny
                              : Icons.nights_stay;
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

  void _navigateToMedicationSelection() {
    _medicationTimes.sort((a, b) {
      return (a['hour'] * 60 + a['minute']).compareTo(
        b['hour'] * 60 + b['minute'],
      );
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MedicationSelectionScreen(
              times: List.from(_medicationTimes),
              currentIndex: 0,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
            ),
            SizedBox(height: 10),
            Text(
              "약 복용 시간",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "약 시간에 알림을 드립니다",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _medicationTimes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          _medicationTimes[index]['icon'],
                          color: Colors.amber,
                        ),
                        ToggleButtons(
                          isSelected: [
                            _medicationTimes[index]['period'] == '오전',
                            _medicationTimes[index]['period'] == '오후',
                          ],
                          onPressed: (int selectedIndex) {
                            setState(() {
                              _medicationTimes[index]['period'] =
                                  selectedIndex == 0 ? '오전' : '오후';
                              _medicationTimes[index]['icon'] =
                                  selectedIndex == 0
                                      ? Icons.wb_sunny
                                      : Icons.nights_stay;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          selectedColor: Colors.white,
                          color: Colors.black,
                          fillColor: Colors.blueAccent,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Text('오전'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Text('오후'),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _showCupertinoTimePicker(index),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "${_medicationTimes[index]['hour'].toString().padLeft(2, '0')} : ${_medicationTimes[index]['minute'].toString().padLeft(2, '0')}",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey),
                          onPressed: () => _removeMedicationTime(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: TextButton(
                onPressed: _addMedicationTime,
                child: Text(
                  "+ 약 시간 추가",
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToMedicationSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "다음",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SleepScheduleScreen extends StatefulWidget {
  @override
  _SleepScheduleScreenState createState() => _SleepScheduleScreenState();
}

class _SleepScheduleScreenState extends State<SleepScheduleScreen> {
  TimeOfDay wakeUpTime = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay bedTime = TimeOfDay(hour: 23, minute: 0);

  void _selectTime(BuildContext context, bool isWakeUp) {
    DateTime initialTime = DateTime(
      2025,
      1,
      1,
      isWakeUp ? wakeUpTime.hour : bedTime.hour,
      isWakeUp ? wakeUpTime.minute : bedTime.minute,
    );

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              // 확인 버튼 추가
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "취소",
                        style: TextStyle(fontSize: 18, color: Colors.redAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "확인",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time, // 시간만 선택
                  initialDateTime: initialTime,
                  use24hFormat: true, // 24시간 형식
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      TimeOfDay pickedTime = TimeOfDay(
                        hour: newTime.hour,
                        minute: newTime.minute,
                      );
                      if (isWakeUp) {
                        wakeUpTime = pickedTime;
                      } else {
                        bedTime = pickedTime;
                      }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 10,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: 0.4,
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
            ),
            SizedBox(height: 10),
            Text(
              "기상 & 취침 시간",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildTimeSelector(context, "🌞 기상 시간", wakeUpTime, true),
            SizedBox(height: 20),
            _buildTimeSelector(context, "🌙 취침 시간", bedTime, false),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  StorageManager().saveSleepSchedule(wakeUpTime, bedTime);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicationScheduleScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "다음",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    TimeOfDay time,
    bool isWakeUp,
  ) {
    return GestureDetector(
      onTap: () => _selectTime(context, isWakeUp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${time.hour.toString().padLeft(2, '0')} : ${time.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicationSelectionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> times;
  final int currentIndex;

  MedicationSelectionScreen({required this.times, required this.currentIndex});

  @override
  _MedicationSelectionScreenState createState() =>
      _MedicationSelectionScreenState();
}

class _MedicationSelectionScreenState extends State<MedicationSelectionScreen> {
  bool get isMorning => widget.times[widget.currentIndex]['hour'] < 12;
  List<String> medications = [
    "고려은단 멀티비타민",
    "더리얼 오메가3",
    "종근당건강 락토핏 골드",
    "더리얼 비타민D3",
    "일양약품 액티브 마그네슘",
  ];
  List<String> selectedMedications = []; // ✅ 여러 개의 약 저장 리스트

  TextEditingController _medicationController = TextEditingController();
  List<DateTime> _selectedDates = [];
  List<String> _formattedDates = [];
  String? _ocrDetectedName;

  void _toggleMedicationSelection(String medication) {
    setState(() {
      if (selectedMedications.contains(medication)) {
        selectedMedications.remove(medication);
      } else {
        selectedMedications.add(medication);
      }
    });
  }

  Future<String?> _handleOCRForSignup() async {
    print("📥 OCR 함수 진입 (Naver Cloud OCR)");

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      print("📷 이미지 선택 취소됨");
      return null;
    }

    final bytes = await File(pickedFile.path).readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse(
      "https://8mx810cn8e.apigw.ntruss.com/custom/v1/39498/3ab994bd8699d77e4b09ed85f26e9d71a204c2a32f4006cc2481c5b1549b2762/general",
    );
    final headers = {
      "X-OCR-SECRET": "bmNsTklGSFFOWnlqSVNKZG9KeE5CTWRId3R3Z0NDeUE=",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "version": "V2",
      "requestId": "medireg_ocr",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "images": [
        {"format": "jpg", "name": "ocr_image", "data": base64Image},
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fields = data['images'][0]['fields'] as List<dynamic>;

        // OCR 전체 텍스트 연결
        final allText = fields.map((f) => f['inferText'].toString()).join(' ');
        print("🧠 OCR 전체 텍스트: $allText");

        // 단어 단위 나누기
        final words =
            allText
                .split(RegExp(r'\s+'))
                .map((w) => w.trim())
                .where((w) => w.isNotEmpty)
                .toList();

        // 필터링된 후보 단어
        final candidates =
            words.where((word) {
              return word.contains(RegExp(r'[가-힣]')) &&
                  word.length >= 2 &&
                  word.length <= 30 &&
                  !word.contains(
                    RegExp(r'(제조자|수입자|서울특별시|의약품안전나라|https|품목허가사항|식약처|용산구|판매)'),
                  );
            }).toList();

        print("🔍 후보 단어: $candidates");

        String? matchedDrug;

        for (final word in candidates) {
          final matches = await ApiService.searchDrugByName(word);
          print("🟢 검색 결과 리스트: ${matches.length}개");
          print("📡 응답 본문: $matches");

          if (matches.isNotEmpty) {
            final keyword =
                word.replaceAll(RegExp(r'[^가-힣a-zA-Z0-9]'), '').toLowerCase();

            final banList = [
              '우먼스',
              '어린이',
              '콜드',
              '에스',
              '8시간',
              '서방',
              '현탁액',
              '코드',
              '액',
              '이알',
              '시럽',
            ];

            List<String> smartFilter(List<String> list) {
              return list.where((item) {
                final lower = item.toLowerCase();
                final cleaned = lower.replaceAll(
                  RegExp(r'(정|밀리그램|500|160|250|정제|서방정)'),
                  '',
                );
                return cleaned.contains(keyword) &&
                    !banList.any((ban) => lower.contains(ban));
              }).toList();
            }

            // 1순위: 스마트 필터로 남은 약
            final preferred = smartFilter(matches);
            if (preferred.isNotEmpty) {
              preferred.sort((a, b) => a.length.compareTo(b.length));
              matchedDrug = preferred.first;
              print("✅ 스마트 필터링 대표 약: $matchedDrug");
            } else {
              // fallback: keyword 포함한 애들 중 제일 짧은 거
              final fallback =
                  matches
                      .where((m) => m.toLowerCase().contains(keyword))
                      .toList();
              if (fallback.isNotEmpty) {
                fallback.sort((a, b) => a.length.compareTo(b.length));
                matchedDrug = fallback.first;
                print("⚠️ fallback 사용된 약: $matchedDrug");
              } else {
                print("💀 최종 fallback: 아무거나 선택");
                matches.sort((a, b) => a.length.compareTo(b.length));
                matchedDrug = matches.first;
              }
            }

            break;
          }
        }
        print("🔍 백엔드 매칭 결과: $matchedDrug");

        if (matchedDrug != null && matchedDrug.isNotEmpty) {
          print("✅ 최종 약 이름: $matchedDrug");
          setState(() {
            _medicationController.text = matchedDrug!;
          });
        } else {
          print("❌ 약 이름 인식 실패");
        }

        // 날짜 자동 선택
        if (allText.contains("하루 1회") || allText.contains("매일 복용")) {
          final now = DateTime.now();
          final twoWeeks = List<DateTime>.generate(
            14,
            (i) => now.add(Duration(days: i)),
          );

          setState(() {
            _selectedDates = twoWeeks;
            _formattedDates =
                twoWeeks
                    .map((d) => DateFormat('yyyy-MM-dd').format(d))
                    .toList();
          });

          print("📅 '하루 1회' 또는 '매일 복용' 감지됨 → 2주 날짜 자동 선택 완료");
        } else {
          print("📅 날짜 자동 선택 조건 해당 없음");
        }
      } else {
        print("❌ 네이버 OCR API 실패: ${response.body}");
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
    }

    return null;
  }

  void _finalSignUp() async {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CupertinoAlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(height: 10),
                Text("회원가입 진행 중..."),
              ],
            ),
          ),
    );
    if (selectedMedications.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("최소 하나 이상의 약을 선택해주세요.")));
      return;
    }

    // ✅ 복약 시간별 약 저장
    String timeKey =
        "${widget.times[widget.currentIndex]['hour']}:${widget.times[widget.currentIndex]['minute']}";
    StorageManager().saveSelectedMedications(timeKey, selectedMedications);

    // ✅ 모든 정보 불러오기
    Map<String, dynamic> userData = StorageManager().getAllData();
    print("🟢 회원가입 요청 데이터: $userData"); // 🚀 회원가입 전 데이터 확인

    try {
      // ✅ 1. 회원가입 수행 → userId 반환
      String userId = await ApiService.signUp(
        userId: userData["user"]["email"], // ✅ 이제 그냥 ID로 사용 (이메일 아님)
        username: userData["user"]["name"],
        password: userData["user"]["password"],
        birthdate: userData["user"]["birthdate"] ?? "", // 👈 null-safe 처리
        gender: userData["gender"] ?? "", // 👈 null-safe 처리
        wakeUpTime: formatTime(userData["sleepSchedule"]["wakeUp"]),
        sleepTime: formatTime(userData["sleepSchedule"]["bedTime"]),
      );

      print("✅ 회원가입 성공 - userId: $userId");

      // ✅ 2. 복약 일정 저장 (medicationTimes가 비어 있지 않은 경우만 실행)
      if (userData.isNotEmpty) {
        for (var entry in userData["medications"].entries) {
          String time = entry.key; // "9:0"처럼 저장된 값

          // ✅ HH:mm 형식으로 변환
          List<String> timeParts = time.split(":");
          String formattedTime =
              "${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}";

          List<String> medications = entry.value;

          print("🟢 [요청 확인] ${formattedTime} 시간에 복약 일정 추가 요청: $medications");

          for (var mediName in medications) {
            for (int i = 0; i < 14; i++) {
              // ✅ 30일 반복 저장
              DateTime futureDate = DateTime.now().add(
                Duration(days: i),
              ); // 오늘 + i일

              MedicationSchedule scheduleData = await ApiService.createSchedule(
                userId: userData["user"]["email"], // ✅ 이제 그냥 ID로 사용 (이메일 아님)
                mediName: mediName,
                tmDate:
                    futureDate.toString().split(' ')[0], // YYYY-MM-DD (30일 반복)
                tmTime: formattedTime, // ✅ 올바른 HH:mm 형식 전달
              );

              print(
                "✅ [${futureDate.toString().split(' ')[0]}] 복약 일정 저장 완료 - 일정 ID: ${scheduleData.tmIdx}",
              );
            }
          }
        }
      }
      print("✅ 회원가입 및 복약 일정 저장 완료!");

      // ✅ 4. 로그인 화면으로 이동 (LoginScreen으로 직접 이동)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } catch (e, stackTrace) {
      print("🚨 오류 발생: $e");
      print("🛠️ 스택 트레이스: $stackTrace"); // 스택 트레이스 출력

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("회원가입 실패: $e")));
    }
  }

  void _addNewMedication() {
    TextEditingController medicationController = TextEditingController();
    String? ocrResult;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "약 추가하기 (OCR 지원)",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_ocrDetectedName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          "📸 인식된 약 이름: $_ocrDetectedName",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: medicationController,
                            decoration: InputDecoration(
                              hintText: "약 이름 입력",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.indigoAccent,
                          ),
                          onPressed: () async {
                            String? result = await _handleOCRForSignup();
                            if (result != null && result.isNotEmpty) {
                              setState(() {
                                _ocrDetectedName = result;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "취소",
                            style: TextStyle(color: Colors.indigoAccent),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (medicationController.text.isNotEmpty) {
                              setState(() {
                                medications.add(medicationController.text);
                                selectedMedications.add(
                                  medicationController.text,
                                ); // 자동 선택도 함께 수행
                              });
                            }
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("추가"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isMorning ? 'assets/morning_bg.jpg' : 'assets/evening_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value:
                          0.8 +
                          (0.2 * widget.currentIndex / widget.times.length),
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "${widget.times[widget.currentIndex]['hour'].toString().padLeft(2, '0')}:${widget.times[widget.currentIndex]['minute'].toString().padLeft(2, '0')} ${isMorning ? '오전' : '오후'} 복용약",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: medications.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedMedications.contains(
                              medications[index],
                            );
                            return GestureDetector(
                              onTap:
                                  () => _toggleMedicationSelection(
                                    medications[index],
                                  ), // ✅ 다중 선택 기능 추가
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.indigoAccent
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.indigoAccent
                                              : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      medications[index],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: _addNewMedication,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_hospital, color: Colors.black),
                              SizedBox(width: 5),
                              Text(
                                "약 추가하기",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              selectedMedications.isNotEmpty
                                  ? () {
                                    // ✅ 현재 선택한 약 정보 저장
                                    StorageManager().saveSelectedMedications(
                                      "${widget.times[widget.currentIndex]['hour']}:${widget.times[widget.currentIndex]['minute']}",
                                      selectedMedications,
                                    );

                                    if (widget.currentIndex <
                                        widget.times.length - 1) {
                                      // ✅ 아직 선택해야 할 약 복용 시간이 남아 있으면 다음 화면으로 이동
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  MedicationSelectionScreen(
                                                    times: widget.times,
                                                    currentIndex:
                                                        widget.currentIndex + 1,
                                                  ),
                                        ),
                                      );
                                    } else {
                                      // ✅ 마지막 복용 약 선택이 끝나면 회원가입 완료 & 로그인 화면 이동
                                      _finalSignUp();
                                    }
                                  }
                                  : null, // ✅ 약이 선택되지 않으면 버튼 비활성화
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                selectedMedications.isNotEmpty
                                    ? Colors.indigoAccent
                                    : Colors.grey,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.currentIndex < widget.times.length - 1
                                ? "다음"
                                : "회원가입 완료", // ✅ 마지막 버튼일 때 "회원가입 완료"로 변경
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String formatTime(String time) {
  // "7:0" 같은 형식을 "07:00"으로 변환
  List<String> parts = time.split(':');
  String hour = parts[0].padLeft(2, '0');
  String minute = parts.length > 1 ? parts[1].padLeft(2, '0') : "00";
  return "$hour:$minute";
}
