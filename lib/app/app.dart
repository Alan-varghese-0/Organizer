import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/app/theme/app_theme.dart';
import 'package:organizer/app/theme/theme_notifier.dart';
import 'package:organizer/features/splash/presentation/screens/splash_screen.dart';

class OrganizerApp extends StatefulWidget {
  final String? personality;

  const OrganizerApp({super.key, this.personality});

  @override
  State<OrganizerApp> createState() => _OrganizerAppState();
}

class _OrganizerAppState extends State<OrganizerApp> {
  @override
  void initState() {
    super.initState();
    // Seed the notifier + color tokens with the value read at launch
    final initial = (widget.personality != null && widget.personality!.isNotEmpty)
        ? widget.personality!
        : 'Aurora';
    personalityNotifier.value = initial;
    AppColor.applyPersonality(initial);

    personalityNotifier.addListener(_onPersonalityChanged);
  }

  @override
  void dispose() {
    personalityNotifier.removeListener(_onPersonalityChanged);
    super.dispose();
  }

  void _onPersonalityChanged() {
    // 1. Update AppColor static tokens → all widgets reading AppColor.primary etc. get new values
    AppColor.applyPersonality(personalityNotifier.value);
    // 2. Rebuild root → MaterialApp gets new ThemeData + all widgets repaint
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.themeForPersonality(personalityNotifier.value);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      home: SplashScreen(),
    );
  }
}
