import 'package:flutter/material.dart';
import 'package:organizer/app/app.dart';
import 'package:organizer/core/database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  runApp(const OrganizerApp());
}
