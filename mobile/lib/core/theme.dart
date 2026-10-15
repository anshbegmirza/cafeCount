import 'package:flutter/material.dart';

/// Hidden Room design tokens — light only (docs/DESIGN_SYSTEM.md).
class HrColors {
  static const forest = Color(0xFF212621);
  static const cream = Color(0xFFE6E3DB);
  static const forestLift = Color(0xFF2E3530);
  static const mist = Color(0xFFF4F1EC);
  static const paper = Color(0xFFFFFEFA);
  static const ink = Color(0xFF1C1F1C);
  static const muted = Color(0xFF6B716B);
  static const line = Color(0xFFD8D4CC);
  static const ok = Color(0xFF2F6B4F);
  static const low = Color(0xFFC4A035);
  static const out = Color(0xFFC45C4A);
}

ThemeData buildLightTheme() {
  const scheme = ColorScheme.light(
    primary: HrColors.forest,
    onPrimary: HrColors.cream,
    secondary: HrColors.forestLift,
    onSecondary: HrColors.cream,
    surface: HrColors.paper,
    onSurface: HrColors.ink,
    error: HrColors.out,
    onError: HrColors.cream,
    outline: HrColors.line,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: HrColors.mist,
    appBarTheme: const AppBarTheme(
      backgroundColor: HrColors.mist,
      foregroundColor: HrColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: HrColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'serif',
      ),
    ),
    cardTheme: CardThemeData(
      color: HrColors.paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: HrColors.line),
      ),
    ),
    dividerColor: HrColors.line,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: HrColors.forest,
      foregroundColor: HrColors.cream,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: HrColors.paper,
      selectedColor: HrColors.forest,
      disabledColor: HrColors.line,
      labelStyle: const TextStyle(color: HrColors.ink, fontSize: 14),
      secondaryLabelStyle: const TextStyle(color: HrColors.cream, fontSize: 14),
      side: const BorderSide(color: HrColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HrColors.paper,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: HrColors.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: HrColors.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: HrColors.forest, width: 1.5)),
      labelStyle: const TextStyle(color: HrColors.muted, fontSize: 16),
      hintStyle: const TextStyle(color: HrColors.muted, fontSize: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: HrColors.forest,
        foregroundColor: HrColors.cream,
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: HrColors.forest,
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: HrColors.forest),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: HrColors.forest, textStyle: const TextStyle(fontSize: 16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: HrColors.paper,
      indicatorColor: HrColors.cream,
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        final selected = s.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? HrColors.forest : HrColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((s) {
        final selected = s.contains(WidgetState.selected);
        return IconThemeData(color: selected ? HrColors.forest : HrColors.muted, size: 24);
      }),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: HrColors.ink),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: HrColors.ink),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: HrColors.ink),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: HrColors.ink),
      bodyLarge: TextStyle(fontSize: 16, color: HrColors.ink),
      bodyMedium: TextStyle(fontSize: 16, color: HrColors.ink),
      bodySmall: TextStyle(fontSize: 14, color: HrColors.muted),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: HrColors.muted),
    ),
  );
}
