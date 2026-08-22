import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gep/core/constants/env.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gep/cubits/auth/auth_cubit.dart';
import 'package:gep/cubits/theme/theme_cubit.dart';
import 'package:gep/services/about_me/about_me_service.dart';
import 'package:gep/services/admissions/admissions_services.dart';
import 'package:gep/services/analytics/analytics_service.dart';
import 'package:gep/services/auth/auth_admin_service.dart';
import 'package:gep/services/banner/banner_service.dart';
import 'package:gep/services/courses_outline/courses_outline_service.dart';
import 'package:gep/services/enrolled_students/enrolled_students_services.dart';
import 'package:gep/services/notes/notes_service.dart';
import 'package:gep/services/storage/storage_service.dart';
import 'package:gep/services/updates/updates_services.dart';

import 'firebase_options.dart';
import 'gep_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AdminCubit(
            NotesService(),
            StorageService(),
            CoursesOutlineService(),
            AdmissionsService(),
            BannerService(),
            AboutMeService(),
            UpdatesServices(),
            EnrolledStudentsServices(AnalyticsService()),
          ),
        ),
        BlocProvider(create: (context) => AuthCubit(AdminAuthService())),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: MyApp(observer: observer),
    ),
  );
}
