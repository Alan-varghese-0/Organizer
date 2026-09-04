import 'package:flutter/material.dart';
import 'package:organizer/app/app.dart';
import 'package:organizer/core/database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();

  // Read saved personality and pass it to the app so the theme can be created from it
  final settings = DatabaseService.instance.getSettings();
  final personality = (settings['personality'] as String?) ?? '';

  runApp(OrganizerApp(personality: personality));
}
