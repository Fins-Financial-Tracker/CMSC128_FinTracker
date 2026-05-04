# Themes

### Theme definitions (actual colors / ThemeData)
- `lib/themes/constants/app_colors.dart`  

- `lib/themes/logic/app_themes.dart`  
  Builds the `ThemeData` for each theme (`blue`, `pink`, `green`, `orange`, `cyan`, `purple`) using `AppColors.*`. Also contains the `ThemeShortcut` extension (e.g., `context.primary`, `context.surface`, etc.).  

- `lib/themes/constants/app_theme_type.dart`  
  The `enum AppThemeType` listing the theme choices.  

### Theme state / switching logic
- `lib/themes/logic/theme_controller.dart`  
  Holds the current theme in a `ValueNotifier<AppThemeType>` and exposes `setTheme(...)`.  

### Theme picker UI (lets user choose themes)
- `lib/pages/builders/widgets/profile_and_settings/theme_selector_popup.dart`  
  UI dialog that displays the theme options and confirms selection.  

### Platform-level theme color (web shell, not Flutter ThemeData)
- `web/manifest.json`  
  Contains `"theme_color"` and `"background_color"` for the PWA/browser UI.  


# How it works
Theme changing is handled by **three connected parts**:

1) **Where the theme is applied (rebuilds MaterialApp when theme changes)**  
In `lib/main.dart`, `MyApp` wraps `MaterialApp` in a `ValueListenableBuilder` listening to `ThemeController.notifier`. When `notifier.value` changes, Flutter rebuilds and `theme: getTheme(themeType)` updates the app theme.  
```dart name=lib/main.dart url=https://github.com/aalaserna/CMSC128_FinTracker/blob/1169088dd52fc0b3761e8b689228ed93acd46f36/lib/main.dart#L68-L97
return ValueListenableBuilder<AppThemeType>(
  valueListenable: ThemeController.notifier,
  builder: (context, themeType, _){
    return MaterialApp(
      theme: getTheme(themeType),
      ...
    );
  },
);
```

2) **What triggers the theme change (user action in Settings)**  
In `lib/pages/settings_page.dart`, when the user confirms a theme in `ThemeSelectorPopup`, it calls `ThemeController.setTheme(newTheme);`.  
```dart name=lib/pages/settings_page.dart url=https://github.com/aalaserna/CMSC128_FinTracker/blob/1169088dd52fc0b3761e8b689228ed93acd46f36/lib/pages/settings_page.dart#L73-L108
onConfirm: (newTheme) {
  setState(() {
    _currentTheme = newTheme;
  });
  ThemeController.setTheme(newTheme);
}
```

3) **The state holder (stores current theme + notifies listeners)**  
`lib/themes/logic/theme_controller.dart` updates the `ValueNotifier`, which notifies `ValueListenableBuilder` in `main.dart`.  
```dart name=lib/themes/logic/theme_controller.dart url=https://github.com/aalaserna/CMSC128_FinTracker/blob/1169088dd52fc0b3761e8b689228ed93acd46f36/lib/themes/logic/theme_controller.dart#L1-L12
static final ValueNotifier<AppThemeType> notifier =
    ValueNotifier(AppThemeType.blue);

static void setTheme(AppThemeType type) {
  notifier.value = type;
}
```

And `getTheme(...)` in `lib/themes/logic/app_themes.dart` maps the selected `AppThemeType` to the correct `ThemeData`.

# How to Change the Theme

## 1) Change the actual colors (most common)
Edit:
- `lib/themes/constants/app_colors.dart`  
  https://github.com/aalaserna/CMSC128_FinTracker/blob/1169088dd52fc0b3761e8b689228ed93acd46f36/lib/themes/constants/app_colors.dart

Steps:
1. Pick the theme you want (e.g. `_BlueColorCollection`, `_PinkColorCollection`, etc.).
2. Change the `Color(0xFF...)` values for fields like:
   - `pageBackground`, `cardBackground`, `activeElement`, `bodyText`, etc.
3. Hot reload / restart and verify screens using those colors.

This is the intended “edit colors here” file (it’s even documented at the top).

## 2) Ensure the ThemeData uses your colors correctly
Edit:
- `lib/themes/logic/app_themes.dart`  
  https://github.com/aalaserna/CMSC128_FinTracker/blob/1169088dd52fc0b3761e8b689228ed93acd46f36/lib/themes/logic/app_themes.dart

Steps:
1. Check each theme getter (`blue`, `pink`, `green`, etc.) and confirm it references the correct palette.
2. Fix mappings if needed.

Important: in your current code, several themes appear to still use **pink** colors for background/primary/surface (likely copy-paste). For example `green`, `orange`, `cyan`, `purple` are using `AppColors.pink.pageBackground` / `AppColors.pink.activeElement` / etc. If you want truly distinct themes, update those to `AppColors.green...`, `AppColors.orange...`, etc.

## 3) Add a brand-new theme (optional)
Steps:
1. In `lib/themes/constants/app_colors.dart`: add a new color collection class (e.g. `_RedColorCollection`) and expose it from `AppColors` (e.g. `static const red = _RedColorCollection();`).
2. In `lib/themes/constants/app_theme_type.dart`: add the enum value (e.g. `red,`).
3. In `lib/themes/logic/app_themes.dart`:
   - add `static ThemeData get red => _build(... AppColors.red....);`
   - update `getTheme(AppThemeType type)` switch to return `AppThemes.red` for `AppThemeType.red`.
4. The theme picker UI (`ThemeSelectorPopup`) uses `AppThemeType.values`, so it should automatically include the new theme, but you may need to ensure the UI draws a proper preview for it (depends on how `_buildThemeChoice` is implemented later in that file).

## 4) Test theme switching
- Open Settings → Change theme → Confirm.
- This calls `ThemeController.setTheme(newTheme)` and causes `MaterialApp(theme: getTheme(themeType))` in `main.dart` to rebuild.