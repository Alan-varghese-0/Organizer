import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_theme.dart';
import 'package:organizer/features/splash/presentation/screens/splash_screen.dart';

class OrganizerApp extends StatelessWidget {
  const OrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }
}
