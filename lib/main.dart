import 'package:flutter/material.dart';
import 'package:selc/utils/themes.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SELC',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: const LoginScreen(),
    );
  }
}
