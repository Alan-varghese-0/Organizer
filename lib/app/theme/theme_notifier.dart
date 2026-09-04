import 'package:flutter/material.dart';

/// Global notifier for the active personality/theme name.
/// Update this from Settings or Workspace Setup to rebuild the app theme immediately.
final personalityNotifier = ValueNotifier<String>('Aurora');
