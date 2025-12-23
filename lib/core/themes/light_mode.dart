import 'package:flutter/material.dart';

ThemeData get lightMode {
  const surface = Color(0xFFF5F5F7);
  const card = Color(0xFFFFFFFF);
  const cardAlt = Color(0xFFF2F2F7);
  const textPrimary = Color(0xFF1D1D1F);
  const textSecondary = Color(0xFF86868B);
  const divider = Color(0xFFE5E5EA);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.light(
      surface: surface,
      primary: textSecondary,
      secondary: card,
      tertiary: cardAlt,
      inversePrimary: textPrimary,
      onPrimary: Color(0xFF3A3A3C),
      outline: divider,
      shadow: Color(0x1A000000),
    ),
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: card,
      foregroundColor: textPrimary,
      centerTitle: false,
    ),
    dividerColor: divider,
    cardTheme: CardThemeData(
      elevation: 0,
      color: card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: textPrimary,
      foregroundColor: card,
      elevation: 2,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
