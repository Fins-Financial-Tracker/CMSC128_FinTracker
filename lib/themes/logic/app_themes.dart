import 'package:flutter/material.dart';
import 'package:fins/themes/constants/app_colors.dart';
import 'package:fins/themes/constants/app_theme_type.dart';
export 'package:fins/themes/constants/app_theme_type.dart';

/*
===========================================================================
   This file contains the logic for themes and reuses the app colors class.
   It also uses the enum types on app theme types for the getters.
===========================================================================
*/

// this is for the customized widgets
class ExtraColors extends ThemeExtension<ExtraColors> {
  final Color bubble;
  final Color themeItemIcon;
  final Color hintText;

  const ExtraColors({
    required this.bubble,
    required this.themeItemIcon,
    required this.hintText,
  });

  @override
  ExtraColors copyWith() => this;

  // lerp means linear interpolation. it finds the middle ground value for a smooth animation
  @override
  ExtraColors lerp(ThemeExtension<ExtraColors>? newTheme, double t) {
    if (newTheme is! ExtraColors) return this;
    return ExtraColors(
      bubble: Color.lerp(bubble, newTheme.bubble, t)!,
      themeItemIcon: Color.lerp(themeItemIcon, newTheme.themeItemIcon, t)!,
      hintText: Color.lerp(hintText, newTheme.hintText, t)!,
    );
  }
}

// Design elements for themed pages (image paths and component colors)
class DesignElements extends ThemeExtension<DesignElements> {
  final Color formContainerColor;
  final String backgroundImagePath;
  final String jeanScrapImagePath;
  final String leatherTextureImagePath;
  final String buttonImagePath;
  final String jeanAppbarImagePath;

  const DesignElements({
    required this.formContainerColor,
    required this.backgroundImagePath,
    required this.jeanScrapImagePath,
    required this.leatherTextureImagePath,
    required this.buttonImagePath,
    required this.jeanAppbarImagePath,
  });

  @override
  DesignElements copyWith() => this;

  @override
  DesignElements lerp(ThemeExtension<DesignElements>? newTheme, double t) {
    if (newTheme is! DesignElements) return this;
    return DesignElements(
      formContainerColor: Color.lerp(
        formContainerColor,
        newTheme.formContainerColor,
        t,
      )!,
      backgroundImagePath: backgroundImagePath,
      jeanScrapImagePath: jeanScrapImagePath,
      leatherTextureImagePath: leatherTextureImagePath,
      buttonImagePath: buttonImagePath,
      jeanAppbarImagePath: jeanAppbarImagePath,
    );
  }
}

class AppThemes {
  AppThemes._();

  // --- THEME BUILDER ---
  static ThemeData _build({
    required Color background,
    required Color primary,
    required Color onPrimary,
    required Color surface,
    required Color onSurface,
    required Color bubble,
    required Color themeItemIcon,
    required Color hintText,
    required Color formContainerColor,
    required String backgroundImagePath,
    required String jeanScrapImagePath,
    required String leatherTextureImagePath,
    required String buttonImagePath,
    required String jeanAppbarImagePath,
  }) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: onPrimary,
        surface: surface,
        onSurface: onSurface,
      ),
      extensions: [
        ExtraColors(
          bubble: bubble,
          themeItemIcon: themeItemIcon,
          hintText: hintText,
        ),
        DesignElements(
          formContainerColor: formContainerColor,
          backgroundImagePath: backgroundImagePath,
          jeanScrapImagePath: jeanScrapImagePath,
          leatherTextureImagePath: leatherTextureImagePath,
          buttonImagePath: buttonImagePath,
          jeanAppbarImagePath: jeanAppbarImagePath,
        ),
      ],
    );
  }

  // --- ACCESS THEMES HERE ---
  static ThemeData get blue => _build(
    background: AppColors.blue.pageBackground,
    primary: AppColors.blue.activeElement,
    surface: AppColors.blue.cardBackground,
    onPrimary: AppColors.blue.pageTitleText,
    onSurface: AppColors.blue.bodyText,
    bubble: AppColors.blue.bubble,
    themeItemIcon: AppColors.blue.themeItemIcon,
    hintText: AppColors.blue.hintText,
    formContainerColor: AppColors.blue.formContainerColor,
    backgroundImagePath: AppColors.blue.backgroundImagePath,
    jeanScrapImagePath: AppColors.blue.jeanScrapImagePath,
    leatherTextureImagePath: AppColors.blue.leatherTextureImagePath,
    buttonImagePath: AppColors.blue.buttonImagePath,
    jeanAppbarImagePath: AppColors.blue.jeanAppbarImagePath,
  );

  static ThemeData get pink => _build(
    background: AppColors.pink.pageBackground,
    primary: AppColors.pink.activeElement,
    surface: AppColors.pink.cardBackground,
    onPrimary: AppColors.pink.pageTitleText,
    onSurface: AppColors.pink.bodyText,
    bubble: AppColors.pink.bubble,
    themeItemIcon: AppColors.pink.themeItemIcon,
    hintText: AppColors.pink.hintText,
    formContainerColor: AppColors.pink.formContainerColor,
    backgroundImagePath: AppColors.pink.backgroundImagePath,
    jeanScrapImagePath: AppColors.pink.jeanScrapImagePath,
    leatherTextureImagePath: AppColors.pink.leatherTextureImagePath,
    buttonImagePath: AppColors.pink.buttonImagePath,
    jeanAppbarImagePath: AppColors.pink.jeanAppbarImagePath,
  );
}

// Use in UI
extension ThemeShortcut on BuildContext {
  Color get primary => Theme.of(this).colorScheme.primary;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;

  ExtraColors get _extra => Theme.of(this).extension<ExtraColors>()!;
  Color get bubble => _extra.bubble;
  Color get themeIconContainer => _extra.themeItemIcon;
  Color get hintText => _extra.hintText;

  DesignElements get _design => Theme.of(this).extension<DesignElements>()!;
  Color get formContainerColor => _design.formContainerColor;
  String get backgroundImagePath => _design.backgroundImagePath;
  String get jeanScrapImagePath => _design.jeanScrapImagePath;
  String get leatherTextureImagePath => _design.leatherTextureImagePath;
  String get buttonImagePath => _design.buttonImagePath;
  String get jeanAppbarImagePath => _design.jeanAppbarImagePath;
}

ThemeData getTheme(AppThemeType type) {
  switch (type) {
    case AppThemeType.blue:
      return AppThemes.blue;
    case AppThemeType.pink:
      return AppThemes.pink;
  }
}
