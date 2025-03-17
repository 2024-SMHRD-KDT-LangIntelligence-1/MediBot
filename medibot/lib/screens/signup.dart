import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/services/StorageManager.dart';
import 'package:medibot/services/api_service.dart';

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

  bool _isIdChecked = false;
  String? _passwordError;
  String _gender = "M"; // 기본 성별
  String _wakeUpTime = "07:00:00"; // 기본 기상 시간
  String _sleepTime = "23:00:00"; // 기본 취침 시간

  /// ✅ 이메일 중복 확인
  void _checkIdDuplicate() async {
    try {
      bool isDuplicate = await ApiService.checkEmailDuplicate(
        _idController.text,
      );
      setState(() {
        _isIdChecked = !isDuplicate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDuplicate ? "이미 사용 중인 이메일입니다." : "사용 가능한 이메일입니다!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("이메일 중복 확인 실패: $e")));
    }
  }

  /// ✅ 회원가입 요청
  void _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = "비밀번호가 일치하지 않습니다.";
      });
      return;
    }

    if (_ageController.text.isEmpty ||
        int.tryParse(_ageController.text) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("나이를 올바르게 입력하세요.")));
      return;
    }

    try {
      String result = await ApiService.signUp(
        userId: _idController.text,
        username: _nameController.text,
        password: _passwordController.text,
        age: int.parse(_ageController.text), // ✅ birthdate 대신 age 전달
        gender: _gender,
        wakeUpTime: _wakeUpTime,
        sleepTime: _sleepTime,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));

      if (result == "회원가입 성공!") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IntroScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("회원가입 실패: $e")));
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
                  onPressed: _checkIdDuplicate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
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
            _buildTextField(
              _ageController,
              "나이 입력",
              keyboardType: TextInputType.number, // ✅ 숫자 키패드
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: Text(
                  "회원가입",
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
              "약 시간과 병원검사 항목을 설정합니다",
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
  List<String> medications = ["혈압약", "당뇨약", "고지혈약", "유산균", "영양제"];
  List<String> selectedMedications = []; // ✅ 여러 개의 약 저장 리스트

  void _toggleMedicationSelection(String medication) {
    setState(() {
      if (selectedMedications.contains(medication)) {
        selectedMedications.remove(medication);
      } else {
        selectedMedications.add(medication);
      }
    });
  }

  void _addNewMedication() {
    TextEditingController medicationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
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
                  "새로운 약 추가",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: medicationController,
                  decoration: InputDecoration(
                    hintText: "약 이름 입력",
                    filled: true,
                    fillColor: Colors.white,
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
                          });
                        }
                        Navigator.pop(context);
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
                                    if (widget.currentIndex <
                                        widget.times.length - 1) {
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
                                      Navigator.pushNamed(context, "/nextStep");
                                    }
                                  }
                                  : null,
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
                            "다음",
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
