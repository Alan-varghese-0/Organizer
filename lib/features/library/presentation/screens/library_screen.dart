import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Library', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text('Your library items will appear here.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
