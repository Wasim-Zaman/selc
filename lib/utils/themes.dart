import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selc/utils/constants.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightScaffoldBackground,
      foregroundColor: AppColors.lightAppBarForeground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.lightBodyText),
      displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.lightBodyText),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.lightBodyText),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.lightBodyText),
      bodySmall:
          TextStyle(fontSize: 12, color: AppColors.lightBodyTextSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.lightScaffoldBackground,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.lightIcon),
    dividerTheme: const DividerThemeData(color: AppColors.lightDivider),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightCard,
      error: AppColors.error,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkScaffoldBackground,
      foregroundColor: AppColors.darkAppBarForeground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBodyText),
      displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBodyText),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.darkBodyText),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.darkBodyText),
      bodySmall:
          TextStyle(fontSize: 12, color: AppColors.darkBodyTextSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.darkScaffoldBackground,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.darkIcon),
    dividerTheme: const DividerThemeData(color: AppColors.darkDivider),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkCard,
      error: AppColors.error,
    ),
  );
}
