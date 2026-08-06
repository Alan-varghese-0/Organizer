import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  static const Color primary = Colors.white;

  // Backgrounds
  static const Color background = Colors.black; // #000000
  static const Color scaffold = Colors.black;
  static const Color surface = Color(0xFF0F0F0F);

  // Containers
  static const Color card = Color(0xFF171717);
  static const Color elevatedCard = Color(0xFF202020);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF707070);

  // Borders
  static const Color border = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF1F1F1F);

  // Icons
  static const Color iconPrimary = Colors.white;
  static const Color iconSecondary = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Accent (for selections, AI, active tabs, buttons)
  static const Color accent = Color(0xFFFFFFFF);
}
