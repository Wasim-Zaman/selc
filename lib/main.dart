import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/cubits/theme/theme_cubit.dart';
import 'package:selc/services/admissions/admissions_services.dart';
import 'package:selc/services/auth/auth_admin_service.dart';
import 'package:selc/services/banner/banner_service.dart';
import 'package:selc/services/courses_outline/courses_outline_service.dart';
import 'package:selc/services/notes/notes_service.dart';
import 'package:selc/services/playlists/playlist_service.dart';
import 'package:selc/services/storage/storage_service.dart';
import 'package:selc/services/updates/updates_services.dart';
import 'package:selc/utils/themes.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';
import 'package:selc/view/screens/user/dashboard/dashboard_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? user = FirebaseAuth.instance.currentUser;
  Widget initialScreen =
      user != null ? const DashboardScreen() : const LoginScreen();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AdminCubit(
            NotesService(),
            StorageService(),
            CoursesOutlineService(),
            AdmissionsService(),
            PlaylistService(),
            BannerService(),
            UpdatesServices(),
          ),
        ),
        BlocProvider(create: (context) => AuthCubit(AdminAuthService())),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'SELC',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: state.themeMode,
          home: initialScreen,
        );
      },
    );
  }
}
