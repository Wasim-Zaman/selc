// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:selc/services/auth/auth_service.dart';
import 'package:selc/utils/themes.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:selc/providers/theme_provider.dart';
import 'package:selc/view/screens/user/dashboard/dashboard_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService();
  // await authService.initializeAuth();

  User? user = FirebaseAuth.instance.currentUser;
  Widget initialScreen =
      user != null ? const DashboardScreen() : const LoginScreen();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SELC',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          home: initialScreen,
        );
      },
    );
  }
}
