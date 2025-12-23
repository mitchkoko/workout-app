import 'package:flutter/material.dart';

ThemeData get darkMode {
  const surface = Color(0xFF121212);
  const card = Color(0xFF1A1A1A);
  const cardAlt = Color(0xFF222222);
  const textPrimary = Color(0xFFE6E6E6);
  const textSecondary = Color(0xFF9A9A9A);
  const divider = Color(0xFF2E2E2E);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: textSecondary,
      secondary: card,
      tertiary: cardAlt,
      inversePrimary: textPrimary,
      onPrimary: Color(0xFFE0E0E0),
      outline: divider,
      shadow: Color(0x33000000),
      surfaceTint: Colors.transparent,
    ),
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: card,
      foregroundColor: textPrimary,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    dividerColor: divider,
    cardTheme: CardThemeData(
      elevation: 0,
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 2,
    ),
    iconTheme: const IconThemeData(color: textSecondary),
    dialogTheme: const DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: card,
      modalBackgroundColor: card,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: textSecondary,
      textColor: textPrimary,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(color: card),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
