import 'package:flutter/material.dart';
import 'medication_registration_screen.dart';
import 'medication_schedule.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // backgroundColor: Colors.grey[100],
      body: MedicationRecordScreen(), // AppBar 없이 바로 호출
    );
  }
}
