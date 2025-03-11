import 'package:flutter/material.dart';
import 'medication_registration_screen.dart';
import 'medication_schedule.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("홈 화면"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: const MedicationRecordScreen(),
        // child: ElevatedButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => const MedicationRegistrationScreen(),
        //       ),
        //     );
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.black,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        //   ),
        //   child: const Text(
        //     "+ 약 추가",
        //     style: TextStyle(color: Colors.white, fontSize: 18),
        //   ),
        // ),
      ),
    );
  }
}
