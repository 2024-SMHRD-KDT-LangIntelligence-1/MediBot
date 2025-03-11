import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MultiDatePicker extends StatefulWidget {
  final List<DateTime> selectedDates;
  final Function(List<DateTime>) onDatesSelected;

  const MultiDatePicker({
    super.key,
    required this.selectedDates,
    required this.onDatesSelected,
  });

  @override
  _MultiDatePickerState createState() => _MultiDatePickerState();
}

class _MultiDatePickerState extends State<MultiDatePicker> {
  DateTime _focusedDay = DateTime.now();
  List<DateTime> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _selectedDates = List.from(widget.selectedDates);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "복용 날짜 *",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // 📌 달력 컨테이너 (둥근 카드 스타일 적용)
        Container(
          padding: const EdgeInsets.all(16), // ✅ 내부 여백 추가
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // ✅ 둥글게
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,

            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronIcon: const Icon(
                CupertinoIcons.left_chevron,
                color: Colors.black,
              ),
              rightChevronIcon: const Icon(
                CupertinoIcons.right_chevron,
                color: Colors.black,
              ),
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,

              // ✅ 선택한 날짜 스타일
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),

              // ✅ 오늘 날짜 스타일 (회색으로 은은하게 표시)
              todayDecoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),

              // ✅ 연속된 날짜 선택 시 배경 강조
              rangeHighlightColor: Colors.blueAccent.withOpacity(0.2),

              // ✅ 달력 숫자 스타일
              defaultTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              weekendTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),

            rowHeight: 42, // ✅ 달력 칸 높이 조정 (애플스럽게)
            daysOfWeekHeight: 24,

            // ✅ 날짜 선택 로직
            selectedDayPredicate: (day) => _selectedDates.contains(day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_selectedDates.contains(selectedDay)) {
                  _selectedDates.remove(selectedDay);
                } else {
                  _selectedDates.add(selectedDay);
                }
                _selectedDates.sort(); // ✅ 선택한 날짜 정렬
                widget.onDatesSelected(_selectedDates);
              });
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
