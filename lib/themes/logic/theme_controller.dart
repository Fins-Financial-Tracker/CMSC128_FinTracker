import 'package:flutter/material.dart';
import 'package:fins/themes/logic/app_themes.dart';
import 'package:fins/themes/constants/app_theme_type.dart';

class ThemeController {
  // Update ValueNotifier, which notifies ValueListenableBuilder in main.dart
  static final ValueNotifier<AppThemeType> notifier = ValueNotifier(AppThemeType.blue);

  static void setTheme(AppThemeType type) {
    notifier.value = type;
  }

}