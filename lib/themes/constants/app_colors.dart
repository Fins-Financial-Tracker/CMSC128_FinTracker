import 'package:flutter/material.dart';

/*
==================================================================================
   This file contains the app colors for the supported themes.
   Keep shared design element paths here so pages can pull them from theme data.
==================================================================================
*/

class AppColors {
  AppColors._();

  static const blue = _BlueColorCollection(); // DEFAULT BLUE THEME
  static const pink = _PinkColorCollection();
}

class _BlueColorCollection {
  const _BlueColorCollection();

  // background colors for page, card, and field
  final pageBackground = const Color(0xFFDDE4EE);
  final cardBackground = const Color(0xFFBFC8D6);
  final fieldBackground = const Color(0xFFFFFFFF); // white

  // widget colors
  final lightDivider = const Color(0xFFD0D7E2);
  final darkDivider = const Color(0xFF6C80A4);
  final icon = const Color(0xFF8694AD);
  final container = const Color(0xFFC7D7F0); //container for profile and settings page
  final bubble = const Color(0xFFC3D4F0);
  final activeElement = const Color(0xFF1E2A3A);
  final themeItemIcon = const Color(0xFF8694AD);
  final dateContainer = const Color(0x000000ff);

  // text colors
  final pageTitleText = const Color(0xFF1C2340);
  final bodyText = const Color(0xFF2E3A59);
  final hintText = const Color(0xFF8A9BB5);

  // design elements - denim theme
  final formContainerColor = const Color(0xFF70372A);
  final backgroundImagePath = 'assets/images/denim/background.png';
  final jeanScrapImagePath = 'assets/images/denim/jean_scrap.png';
  final leatherTextureImagePath = 'assets/images/denim/leather.png';
  final buttonImagePath = 'assets/images/denim/button.png';
  final jeanAppbarImagePath = 'assets/images/denim/jean.png';
}

class _PinkColorCollection {
  const _PinkColorCollection();

  // background colors for page, card, and field
  final pageBackground = const Color(0xFFF7E7FF);
  final cardBackground = const Color(0xFFDDBCCD);
  final fieldBackground = const Color(0xFFFFFFFF); // white

  // widget colors
  final lightDivider = const Color(0xFFF9D5EB);
  final darkDivider = const Color(0xFFC282A3);
  final icon = const Color(0xFF3A1E2E);
  final container = const Color(0xFFC7D7F0); //container for profile and settings page
  final bubble = const Color(0xFFF6BCDF);
  final activeElement = const Color(0xFF3A1E2E);
  final themeItemIcon = const Color(0xFFF0C3DE);
  final dateContainer = const Color(0xFFF0C3DE);

  // text colors
  final pageTitleText = const Color(0xFF3A1E2E);
  final bodyText = const Color(0xFF84355E);
  final hintText = const Color(0xFFC282A3);

  // design elements - denim theme
  final formContainerColor = const Color(0xFF70372A);
  final backgroundImagePath = 'assets/images/denim/background.png';
  final jeanScrapImagePath = 'assets/images/denim/jean_scrap.png';
  final leatherTextureImagePath = 'assets/images/denim/leather.png';
  final buttonImagePath = 'assets/images/denim/button.png';
  final jeanAppbarImagePath = 'assets/images/denim/jean.png';
}
