import 'package:flutter/material.dart';
import 'package:selc/utils/constants.dart';

class AppThemes {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // primarySwatch: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightAppBarBackground,
      foregroundColor: AppColors.lightAppBarForeground,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.lightButton, // Primary color of buttons
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.lightBodyText),
      bodySmall: TextStyle(color: AppColors.lightBodyTextSecondary),
    ),
    cardColor: AppColors.lightCard,
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // primarySwatch: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkAppBarBackground,
      foregroundColor: AppColors.darkAppBarForeground,
      elevation: 0,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.darkButton,
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.darkBodyText),
      bodySmall: TextStyle(color: AppColors.darkBodyTextSecondary),
    ),
    cardColor: AppColors.darkCard,
  );
}
