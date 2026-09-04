import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // These are mutable so they can be updated when the personality/theme changes.
  // Widgets read these directly, so changing them and calling setState on the root
  // widget causes every widget to repaint with the new colors.

  static Color primary = const Color(0xFF8B5CF6);
  static Color primarySoft = const Color(0xFFB794F4);
  static Color primaryDark = const Color(0xFF6D28D9);

  // Backgrounds — constant dark palette
  static const Color background = Color(0xFF0A0B12);
  static const Color scaffold = Color(0xFF0F1118);
  static const Color surface = Color(0xFF151922);
  static const Color surfaceAlt = Color(0xFF1D2330);

  // Containers
  static const Color card = Color(0xFF171B26);
  static const Color elevatedCard = Color(0xFF202734);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB9BED0);
  static const Color textMuted = Color(0xFF7D8399);

  // Borders
  static const Color border = Color(0xFF2B3242);
  static const Color divider = Color(0xFF1D2330);

  // Icons
  static const Color iconPrimary = Colors.white;
  static const Color iconSecondary = Color(0xFF9AA3B8);

  // Status
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);

  // Accent (mirrors primary)
  static Color accent = const Color(0xFF8B5CF6);

  /// Call this whenever the personality changes.
  /// Updates the mutable color tokens so every widget
  /// that reads AppColor.primary etc. gets the new color on rebuild.
  static void applyPersonality(String personality) {
    switch (personality.toLowerCase()) {
      case 'ocean':
        primary = const Color(0xFF2563EB);
        primarySoft = const Color(0xFF60A5FA);
        primaryDark = const Color(0xFF1D4ED8);
        accent = const Color(0xFF38BDF8);
        break;
      case 'forest':
        primary = const Color(0xFF15803D);
        primarySoft = const Color(0xFF4ADE80);
        primaryDark = const Color(0xFF166534);
        accent = const Color(0xFF22C55E);
        break;
      case 'sunset':
        primary = const Color(0xFFF97316);
        primarySoft = const Color(0xFFFDBA74);
        primaryDark = const Color(0xFFEA580C);
        accent = const Color(0xFFFBBF24);
        break;
      case 'aurora':
        primary = const Color(0xFF8B5CF6);
        primarySoft = const Color(0xFFB794F4);
        primaryDark = const Color(0xFF6D28D9);
        accent = const Color(0xFF8B5CF6);
        break;
      case 'noir':
        primary = const Color(0xFF6B7280);
        primarySoft = const Color(0xFF9CA3AF);
        primaryDark = const Color(0xFF374151);
        accent = const Color(0xFF9CA3AF);
        break;
      default:
        primary = const Color(0xFF8B5CF6);
        primarySoft = const Color(0xFFB794F4);
        primaryDark = const Color(0xFF6D28D9);
        accent = const Color(0xFF8B5CF6);
    }
  }
}
