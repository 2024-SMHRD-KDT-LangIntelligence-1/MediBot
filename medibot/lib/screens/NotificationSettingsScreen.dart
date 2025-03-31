import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getBool('notifications_enabled');
    if (savedValue != null) {
      setState(() {
        _notificationsEnabled = savedValue;
      });
    }
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "알림 설정",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text("복약 알림 받기"),
            value: _notificationsEnabled,
            activeColor: Colors.indigoAccent,
            onChanged: (val) async {
              setState(() {
                _notificationsEnabled = val;
              });
              await _saveNotificationSetting(val);
            },
          ),
          const Divider(),
          if (_notificationsEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "알림은 복약 시간에 맞춰 자동으로 전송됩니다.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }
}
