import 'package:flutter/material.dart';

// This file contains the app colors for all 6 selected themes.
// Theme colors: contains the background colors, accent colors, and text colors

class AppColors {

  AppColors._();

  // DEFAULT BLUE THEME
  static const blue = _BlueTheme();

}

class _BlueTheme{
  const _BlueTheme();

  // background colors for page, card, and field
  final pageBackground = const Color(0xFFDDE4EE);
  final cardBackground = const Color(0xFFBFC8D6);
  final fieldBackground =  const Color(0xFFFFFFFF); // white

  // widget colors
  final divider = const Color(0xFFD0D7E2);
  final icon =  const Color(0xFF000000); // black

  // text colors
  final pageTitleText = const Color(0xFF1C2340);
  final bodyText = const Color(0xFF2E3A59);
  final hintText = const Color(0xFF8A9BB5);

}
