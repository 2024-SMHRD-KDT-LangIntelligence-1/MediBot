import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntakeTimeSelector extends StatefulWidget {
  final Function(List<TimeOfDay>) onTimesSelected;

  const IntakeTimeSelector({super.key, required this.onTimesSelected});

  @override
  _IntakeTimeSelectorState createState() => _IntakeTimeSelectorState();
}

class _IntakeTimeSelectorState extends State<IntakeTimeSelector> {
  List<TimeOfDay> _selectedTimes = [];
  TimeOfDay? _tempSelectedTime; // ✅ 사용자가 선택한 시간을 임시 저장

  void _pickTime(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

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
                  onPressed: () {
                    if (_tempSelectedTime != null &&
                        !_selectedTimes.contains(_tempSelectedTime)) {
                      setState(() {
                        _selectedTimes.add(_tempSelectedTime!);
                        widget.onTimesSelected(List.from(_selectedTimes));
                      });
                    }
                    Navigator.pop(context); // ✅ 다이얼로그 닫기
                  },
                  child: const Text(
                    "완료",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedDateTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) {
                    _tempSelectedTime = TimeOfDay(
                      hour: newDate.hour,
                      minute: newDate.minute,
                    ); // ✅ 스크롤할 때는 저장만 하고 추가하지 않음
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeTime(int index) {
    setState(() {
      _selectedTimes.removeAt(index);
      widget.onTimesSelected(List.from(_selectedTimes));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "복약 시간 *",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => _pickTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "시간 추가",
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

        Column(
          children:
              _selectedTimes.asMap().entries.map((entry) {
                int index = entry.key;
                TimeOfDay time = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
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
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
