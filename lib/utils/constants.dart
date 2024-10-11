import 'package:flutter/material.dart';

// Images
class Images {
  static const siginLight = "assets/images/signin_light.png";
  static const signinDark = "assets/images/signin_dark.png";
}

class AppIcons {
  static const siginLight = "assets/icons/signin_light.png";
  static const signinDark = "assets/icons/signin_dark.png";
}

class AppLotties {
  static const aboutMe = "assets/lotties/about_me.json";
  static const admissions = "assets/lotties/admissions.json";
  static const banners = "assets/lotties/banners.json";
  static const courses = "assets/lotties/courses.json";
  static const notes = "assets/lotties/notes.json";
  static const playlist = "assets/lotties/playlist.json";
  static const terms = "assets/lotties/terms.json";
  static const updates = "assets/lotties/updates.json";
  static const youtube = "assets/lotties/youtube.json";
}

// Colors

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1E88E5); // Deep blue
  static const Color secondary = Color(0xFF26A69A); // Teal
  static const Color accent = Color(0xFFFFC107); // Amber

  // Light Theme Colors
  static const Color lightScaffoldBackground =
      Color(0xFFF5F5F5); // Very light grey
  static const Color lightAppBarBackground = Color(0xFFFFFFFF); // White
  static const Color lightAppBarForeground =
      Color(0xFF212121); // Very dark grey
  static const Color lightBodyText = Color(0xFF212121); // Very dark grey
  static const Color lightBodyTextSecondary = Color(0xFF757575); // Medium grey
  static const Color lightCard = Color(0xFFFFFFFF); // White
  static const Color lightIcon = Color.fromARGB(255, 0, 0, 0); // Dark grey
  static const Color lightBorder = Color(0xFFBDBDBD); // Light grey
  static const Color lightDivider = Color(0xFFE0E0E0); // Very light grey

  // Dark Theme Colors
  static const Color darkScaffoldBackground =
      Color(0xFF121212); // Very dark grey
  static const Color darkAppBarBackground = Color(0xFF1E1E1E); // Dark grey
  static const Color darkAppBarForeground = Color(0xFFFFFFFF); // White
  static const Color darkBodyText = Color(0xFFE0E0E0); // Very light grey
  static const Color darkBodyTextSecondary = Color(0xFF9E9E9E); // Medium grey
  static const Color darkCard = Color(0xFF1E1E1E); // Dark grey
  static const Color darkIcon = Color(0xFFFFFFFF); // Light grey
  static const Color darkBorder = Color(0xFF424242); // Medium-dark grey
  static const Color darkDivider = Color(0xFF323232); // Medium-dark grey

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFE53935); // Red
  static const Color warning = Color(0xFFFFA000); // Dark amber
  static const Color info = Color(0xFF2196F3); // Light blue

  // Additional Colors
  static const Color lightNeutral = Color(0xFFF0F0F0); // Very light grey
  static const Color darkNeutral = Color(0xFF2C2C2C); // Dark grey
  static const Color highlightYellow =
      Color(0xFFFFF59D); // Light yellow for text highlighting

  // Random Colors
  static const List<Color> randomColors = [
    Color(0xFF1E88E5), // Deep blue
    Color(0xFF26A69A), // Teal
    Color(0xFFF57C00), // Dark orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF388E3C), // Green
    Color(0xFF0277BD), // Light blue
    Color(0xFFD32F2F), // Red
    Color(0xFF5D4037), // Brown
    Color(0xFF455A64), // Blue grey
    Color(0xFF00796B), // Dark teal
  ];
}

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultBorderWidth = 1.0;
  static const double defaultIconSize = 24.0;
  static const double defaultElevation = 4.0;
}
