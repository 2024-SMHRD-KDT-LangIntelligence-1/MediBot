import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntakeTimeSelector extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onTimesSelected; // ✅ 복용 시간 + 타입 전달

  const IntakeTimeSelector({super.key, required this.onTimesSelected});

  @override
  _IntakeTimeSelectorState createState() => _IntakeTimeSelectorState();
}

class _IntakeTimeSelectorState extends State<IntakeTimeSelector> {
  List<Map<String, dynamic>> _selectedTimes =
      []; // ✅ {"type": "식전", "time": TimeOfDay}
  final List<String> _options = ["식전", "식후"]; // ✅ 선택 옵션
  TimeOfDay? _globalTime; // ✅ 전체 시간 선택 변수 추가

  // 📌 전체 복용 시간 선택 다이얼로그
  void _pickGlobalTime(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "완료",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime.now(),
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _globalTime = TimeOfDay(
                        hour: newDate.hour,
                        minute: newDate.minute,
                      );
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

  // 📌 시간 선택 다이얼로그 (각 아이템별 개별 시간 선택)
  void _pickTime(BuildContext context, int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "완료",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime.now(),
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedTimes[index]["time"] = TimeOfDay(
                        hour: newDate.hour,
                        minute: newDate.minute,
                      );
                      widget.onTimesSelected(_selectedTimes);
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

  // 📌 복용 시간 추가 버튼
  void _addTime(String type) {
    setState(() {
      _selectedTimes.add({
        "type": type,
        "time": _globalTime ?? TimeOfDay.now(), // ✅ 전체 시간 선택 적용
      });
      widget.onTimesSelected(_selectedTimes);
    });
  }

  // 📌 복용 시간 삭제 버튼
  void _removeTime(int index) {
    setState(() {
      _selectedTimes.removeAt(index);
      widget.onTimesSelected(_selectedTimes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📌 "복용 시간" + 전체 시간 설정 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "복용 시간 *",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => _pickGlobalTime(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      _globalTime == null
                          ? "시간 선택"
                          : "${_globalTime!.hourOfPeriod}:${_globalTime!.minute.toString().padLeft(2, '0')} ${_globalTime!.period == DayPeriod.am ? "AM" : "PM"}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 📌 복용 시간 목록
        Column(
          children:
              _selectedTimes.asMap().entries.map((entry) {
                int index = entry.key;
                String type = entry.value["type"];
                TimeOfDay time = entry.value["time"];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        type == "식전"
                            ? CupertinoIcons.sunrise_fill
                            : CupertinoIcons.moon_fill,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                        "$type | ${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? "AM" : "PM"}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          CupertinoIcons.minus_circle_fill,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _removeTime(index),
                      ),
                      onTap: () => _pickTime(context, index),
                    ),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: 12),
        // 📌 "식전 추가" & "식후 추가" 버튼 (🔥 아이콘 추가 완료!)
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _addTime("식전"),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sunny, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "식전 추가",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _addTime("식후"),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.nights_stay, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "식후 추가",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
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
