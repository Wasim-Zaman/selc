import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:selc/utils/themes.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SELC',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: const LoginScreen(),
    );
  }
}
