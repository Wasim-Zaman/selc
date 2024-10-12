// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/cubits/theme/theme_cubit.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/admin/dashboard/about_me/manage_about_me_screen.dart';
import 'package:selc/view/screens/admin/dashboard/admissions/admin_admissions.dart';
import 'package:selc/view/screens/admin/dashboard/banner/manage_banner_screen.dart';
import 'package:selc/view/screens/admin/dashboard/courses_outlines/manage_courses_screen.dart';
import 'package:selc/view/screens/admin/dashboard/enrolled_students/enroll_students_management_screen.dart';
import 'package:selc/view/screens/admin/dashboard/notes/admin_notes_categories_screen.dart';
import 'package:selc/view/screens/admin/dashboard/playlists/playlists_management_screen.dart';
import 'package:selc/view/screens/admin/dashboard/updates/updates_management_screen.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';
import 'package:selc/view/screens/user/dashboard/dashboard_screen.dart';
import 'package:selc/view/widgets/grid_item.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Admin services data with Lottie URLs and gradients
    final List<Map<String, dynamic>> adminServices = [
      {
        'title': 'Manage Notes',
        'lottieUrl': AppLotties.notes,
        'gradient': const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': AdminNotesCategoriesScreen(),
      },
      {
        'title': 'Manage Playlists',
        'lottieUrl': AppLotties.playlist,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const PlaylistsManagementScreen(),
      },
      {
        'title': 'Manage Courses',
        'lottieUrl': AppLotties.courses,
        'gradient': const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const ManageCoursesScreen(),
      },
      {
        'title': 'Manage Updates',
        'lottieUrl': AppLotties.updates,
        'gradient': const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF009688)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const UpdatesManagementScreen(),
      },
      {
        'title': 'Manage Admissions',
        'lottieUrl': AppLotties.admissions,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF4081), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const AdminAdmissionsScreen(),
      },
      {
        'title': 'Manage About Me',
        'lottieUrl': AppLotties.aboutMe,
        'gradient': const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const ManageAboutMeScreen(),
      },
      {
        'title': 'Manage Banner',
        'lottieUrl': AppLotties.banners,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFFA000), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const ManageBannerScreen(),
      },
      {
        'title': 'Manage Enrollment',
        'lottieUrl': AppLotties.students,
        'gradient': const LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': EnrollStudentsManagementScreen(),
      },
    ];
    IconData getFallbackIcon(String title) {
      switch (title) {
        case 'Manage Notes':
          return Icons.note;
        case 'Manage Playlists':
          return Icons.playlist_play;
        case 'Manage Courses':
          return Icons.school;
        case 'Manage Updates':
          return Icons.update;
        case 'Manage Admissions':
          return Icons.person_add;
        case 'Manage About Me':
          return Icons.analytics;
        case 'Manage Banner':
          return Icons.image;
        case 'Manage Enrollment':
          return Icons.how_to_reg;
        default:
          return Icons.dashboard;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: theme.textTheme.headlineSmall),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
              child: Text(
                'Admin Panel',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            ListTile(
              title: const Text('User App'),
              onTap: () {
                Navigations.pushAndRemoveUntil(
                  context,
                  const DashboardScreen(),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await context.read<AuthCubit>().logout();
                Navigations.pushAndRemoveUntil(context, const LoginScreen());
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimary
                                    .withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'SANI',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.admin_panel_settings,
                          size: 48,
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 30,
                      child: Marquee(
                        text:
                            'Welcome to the Admin Dashboard! Manage your app with ease.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 20.0,
                        velocity: 50.0,
                        pauseAfterRound: const Duration(seconds: 1),
                        startPadding: 10.0,
                        accelerationDuration: const Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: const Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adminServices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  return GridItem(
                    title: adminServices[index]['title'],
                    gradient: adminServices[index]['gradient'],
                    screen: adminServices[index]['screen'],
                    lottieUrl: adminServices[index]['lottieUrl'],
                    fallbackIcon: getFallbackIcon(
                      adminServices[index]['title'],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
