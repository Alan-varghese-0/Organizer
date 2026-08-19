import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text('Settings and profile management will appear here.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
