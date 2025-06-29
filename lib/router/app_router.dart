import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:selc/models/course_outline.dart';
import 'package:selc/models/enrolled_students.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/router/app_routes.dart';
import 'package:selc/services/enrolled_students/enrolled_students_services.dart';
import 'package:selc/view/screens/admin/auth/admin_login_screen.dart';
import 'package:selc/view/screens/admin/dashboard/about_me/manage_about_me_screen.dart';
import 'package:selc/view/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:selc/view/screens/admin/dashboard/admissions/admin_admissions.dart';
import 'package:selc/view/screens/admin/dashboard/banner/manage_banner_screen.dart';
import 'package:selc/view/screens/admin/dashboard/courses_outlines/add_course_outline_screen.dart';
import 'package:selc/view/screens/admin/dashboard/courses_outlines/manage_courses_screen.dart';
import 'package:selc/view/screens/admin/dashboard/enrolled_students/add_student_screen.dart';
import 'package:selc/view/screens/admin/dashboard/enrolled_students/edit_student_screen.dart';
import 'package:selc/view/screens/admin/dashboard/enrolled_students/enroll_students_management_screen.dart';
import 'package:selc/view/screens/admin/dashboard/enrolled_students/student_details_screen.dart';
import 'package:selc/view/screens/admin/dashboard/notes/add_notes_screen.dart';
import 'package:selc/view/screens/admin/dashboard/notes/admin_notes_categories_screen.dart';
import 'package:selc/view/screens/admin/dashboard/playlists/add_playlist_screen.dart';
import 'package:selc/view/screens/admin/dashboard/playlists/playlists_management_screen.dart';
import 'package:selc/view/screens/admin/dashboard/updates/updates_management_screen.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';
import 'package:selc/view/screens/user/dashboard/about_me/about_me_screen.dart';
import 'package:selc/view/screens/user/dashboard/about_me/full_screen_resume_screen.dart';
import 'package:selc/view/screens/user/dashboard/about_me/youtube_channel_screen.dart';
import 'package:selc/view/screens/user/dashboard/admissions/admissions_screen.dart';
import 'package:selc/view/screens/user/dashboard/courses_outlines/courses_outlines_screen.dart';
import 'package:selc/view/screens/user/dashboard/dashboard_screen.dart';
import 'package:selc/view/screens/user/dashboard/enrolled_students/enrolled_students_screen.dart';
import 'package:selc/view/screens/user/dashboard/notes/notes_categories_screen.dart';
import 'package:selc/view/screens/user/dashboard/notes/notes_screen.dart';
import 'package:selc/view/screens/user/dashboard/notes/pdf_viewer_screen.dart';
import 'package:selc/view/screens/user/dashboard/playlists/playlist_details_screen.dart';
import 'package:selc/view/screens/user/dashboard/playlists/playlists_screen.dart';
import 'package:selc/view/screens/user/dashboard/terms_and_conditions_screen.dart';
import 'package:selc/view/screens/user/dashboard/updates/updates_screen.dart';
import 'package:selc/view/splash_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.kSplashRoutePath,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.uri.path;

      // If user is on splash screen, redirect based on auth state
      if (location == AppRoutes.kSplashRoutePath) {
        if (user != null) {
          return AppRoutes.kDashboardRoutePath;
        } else {
          return AppRoutes.kLoginRoutePath;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.kSplashRoutePath,
        name: AppRoutes.kSplashRoute,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.kLoginRoutePath,
        name: AppRoutes.kLoginRoute,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.kAdminLoginRoutePath,
        name: AppRoutes.kAdminLoginRoute,
        builder: (context, state) => const AdminLoginScreen(),
      ),

      // Main dashboard
      GoRoute(
        path: AppRoutes.kDashboardRoutePath,
        name: AppRoutes.kDashboardRoute,
        builder: (context, state) => const DashboardScreen(),
      ),

      GoRoute(
        path: AppRoutes.kAdminDashboardRoutePath,
        name: AppRoutes.kAdminDashboardRoute,
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // User screens
      GoRoute(
        path: AppRoutes.kAboutMeRoutePath,
        name: AppRoutes.kAboutMeRoute,
        builder: (context, state) => const AboutMeScreen(),
      ),

      GoRoute(
        path: AppRoutes.kAdmissionsRoutePath,
        name: AppRoutes.kAdmissionsRoute,
        builder: (context, state) => const AdmissionsScreen(),
      ),

      GoRoute(
        path: AppRoutes.kCoursesOutlinesRoutePath,
        name: AppRoutes.kCoursesOutlinesRoute,
        builder: (context, state) => const CoursesOutlinesScreen(),
      ),

      GoRoute(
        path: AppRoutes.kEnrolledStudentsRoutePath,
        name: AppRoutes.kEnrolledStudentsRoute,
        builder: (context, state) => EnrolledStudentsScreen(),
      ),

      GoRoute(
        path: AppRoutes.kNotesCategoriesRoutePath,
        name: AppRoutes.kNotesCategoriesRoute,
        builder: (context, state) => NotesCategoriesScreen(),
      ),

      GoRoute(
        path: AppRoutes.kNotesRoutePath,
        name: AppRoutes.kNotesRoute,
        builder: (context, state) {
          final category = state.uri.queryParameters['category'] ?? '';
          return NotesScreen(category: category);
        },
      ),

      GoRoute(
        path: AppRoutes.kPlaylistsRoutePath,
        name: AppRoutes.kPlaylistsRoute,
        builder: (context, state) => const PlaylistsScreen(),
      ),

      GoRoute(
        path: AppRoutes.kUpdatesRoutePath,
        name: AppRoutes.kUpdatesRoute,
        builder: (context, state) => const UpdatesScreen(),
      ),

      GoRoute(
        path: AppRoutes.kTermsAndConditionsRoutePath,
        name: AppRoutes.kTermsAndConditionsRoute,
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),

      // PDF Viewer
      GoRoute(
        path: AppRoutes.kPdfViewerRoutePath,
        name: AppRoutes.kPdfViewerRoute,
        builder: (context, state) {
          final pdfUrl = state.uri.queryParameters['pdfUrl'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          return PdfViewerScreen(pdfUrl: pdfUrl, title: title);
        },
      ),

      // Resume and YouTube screens
      GoRoute(
        path: AppRoutes.kFullScreenResumeRoutePath,
        name: AppRoutes.kFullScreenResumeRoute,
        builder: (context, state) {
          final resumeUrl = state.uri.queryParameters['resumeUrl'] ?? '';
          return FullScreenResumeScreen(resumeUrl: resumeUrl);
        },
      ),

      GoRoute(
        path: AppRoutes.kYouTubeChannelRoutePath,
        name: AppRoutes.kYouTubeChannelRoute,
        builder: (context, state) {
          final url = state.uri.queryParameters['url'] ?? '';
          return YouTubeChannelScreen(url: url);
        },
      ),

      // Playlist detail
      GoRoute(
        path: AppRoutes.kPlaylistDetailRoutePath,
        name: AppRoutes.kPlaylistDetailRoute,
        builder: (context, state) {
          final playlist = state.extra as PlaylistModel?;
          if (playlist == null) {
            return const Scaffold(
              body: Center(child: Text('Playlist not found')),
            );
          }
          return PlaylistDetailScreen(playlist: playlist);
        },
      ),

      // Student details
      GoRoute(
        path: AppRoutes.kStudentDetailsRoutePath,
        name: AppRoutes.kStudentDetailsRoute,
        builder: (context, state) {
          final student = state.extra as EnrolledStudent?;
          if (student == null) {
            return const Scaffold(
              body: Center(child: Text('Student not found')),
            );
          }
          return StudentDetailsScreen(student: student);
        },
      ),

      // Admin management routes
      GoRoute(
        path: AppRoutes.kManageAboutMeRoutePath,
        name: AppRoutes.kManageAboutMeRoute,
        builder: (context, state) => const ManageAboutMeScreen(),
      ),

      GoRoute(
        path: AppRoutes.kManageBannerRoutePath,
        name: AppRoutes.kManageBannerRoute,
        builder: (context, state) => const ManageBannerScreen(),
      ),

      GoRoute(
        path: AppRoutes.kManageCoursesRoutePath,
        name: AppRoutes.kManageCoursesRoute,
        builder: (context, state) => const ManageCoursesScreen(),
      ),

      GoRoute(
        path: AppRoutes.kAddCourseOutlineRoutePath,
        name: AppRoutes.kAddCourseOutlineRoute,
        builder: (context, state) {
          final courseToEdit = state.extra as Course?;
          return AddCourseOutlineScreen(courseToEdit: courseToEdit);
        },
      ),

      GoRoute(
        path: AppRoutes.kEnrollStudentsManagementRoutePath,
        name: AppRoutes.kEnrollStudentsManagementRoute,
        builder: (context, state) => EnrollStudentsManagementScreen(),
      ),

      GoRoute(
        path: AppRoutes.kAddStudentRoutePath,
        name: AppRoutes.kAddStudentRoute,
        builder: (context, state) {
          final enrolledStudentsServices =
              state.extra as EnrolledStudentsServices?;
          if (enrolledStudentsServices == null) {
            return const Scaffold(
              body: Center(child: Text('Service not available')),
            );
          }
          return AddStudentScreen(
              enrolledStudentsServices: enrolledStudentsServices);
        },
      ),

      GoRoute(
        path: AppRoutes.kEditStudentRoutePath,
        name: AppRoutes.kEditStudentRoute,
        builder: (context, state) {
          final Map<String, dynamic>? extras =
              state.extra as Map<String, dynamic>?;
          if (extras == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid data')),
            );
          }
          final student = extras['student'] as EnrolledStudent?;
          final service = extras['service'] as EnrolledStudentsServices?;

          if (student == null || service == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid data')),
            );
          }

          return EditStudentScreen(
            student: student,
            enrolledStudentsServices: service,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.kAdminNotesCategoriesRoutePath,
        name: AppRoutes.kAdminNotesCategoriesRoute,
        builder: (context, state) => AdminNotesCategoriesScreen(),
      ),

      GoRoute(
        path: AppRoutes.kAddNotesRoutePath,
        name: AppRoutes.kAddNotesRoute,
        builder: (context, state) {
          final category = state.uri.queryParameters['category'] ?? '';
          return AddNotesScreen(category: category);
        },
      ),

      GoRoute(
        path: AppRoutes.kPlaylistsManagementRoutePath,
        name: AppRoutes.kPlaylistsManagementRoute,
        builder: (context, state) => const PlaylistsManagementScreen(),
      ),

      GoRoute(
        path: AppRoutes.kAddPlaylistRoutePath,
        name: AppRoutes.kAddPlaylistRoute,
        builder: (context, state) {
          final playlist = state.extra as PlaylistModel?;
          return AddPlaylistScreen(playlist: playlist);
        },
      ),

      GoRoute(
        path: AppRoutes.kUpdatesManagementRoutePath,
        name: AppRoutes.kUpdatesManagementRoute,
        builder: (context, state) => const UpdatesManagementScreen(),
      ),

      GoRoute(
        path: AppRoutes.kAdminAdmissionsRoutePath,
        name: AppRoutes.kAdminAdmissionsRoute,
        builder: (context, state) => const AdminAdmissionsScreen(),
      ),
    ],
  );

  static GoRouter get router => _router;
}
