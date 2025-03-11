import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MedicationEditScreen extends StatefulWidget {
  final Map<String, dynamic> medication;

  const MedicationEditScreen({super.key, required this.medication});

  @override
  _MedicationEditScreenState createState() => _MedicationEditScreenState();
}

class _MedicationEditScreenState extends State<MedicationEditScreen> {
  late TextEditingController _nameController;
  late List<Map<String, dynamic>> _intakeTimes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication["name"]);
    _intakeTimes = List<Map<String, dynamic>>.from(
      widget.medication["intakeTimes"],
    );
  }

  void _pickTime(int index) async {
    DateTime now = DateTime.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (pickedTime != null) {
      setState(() {
        _intakeTimes[index]["time"] =
            "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _updateType(int index) {
    setState(() {
      _intakeTimes[index]["type"] =
          _intakeTimes[index]["type"] == "식전" ? "식후" : "식전";
    });
  }

  void _saveChanges() {
    Navigator.pop(context, {
      "name": _nameController.text,
      "intakeTimes": _intakeTimes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("약물 수정"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text("저장", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "약 이름",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(controller: _nameController),
            SizedBox(height: 20),
            Text(
              "복용 시간",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children:
                  _intakeTimes.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> time = entry.value;

                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${time["type"]} | ${time["time"]}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.access_time,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () => _pickTime(index),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.swap_horiz,
                                  color: Colors.purpleAccent,
                                ),
                                onPressed: () => _updateType(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
