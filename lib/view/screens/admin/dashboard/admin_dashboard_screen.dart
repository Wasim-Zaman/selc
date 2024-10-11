// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/cubits/theme/theme_cubit.dart';
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
        'lottieUrl':
            'https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json',
        'gradient': const LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': AdminNotesCategoriesScreen(),
      },
      {
        'title': 'Manage Playlists',
        'lottieUrl':
            'https://assets9.lottiefiles.com/private_files/lf30_WdTEui.json',
        'gradient': const LinearGradient(
          colors: [Colors.orange, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const PlaylistsManagementScreen(),
      },
      {
        'title': 'Manage Courses',
        'lottieUrl':
            'https://assets3.lottiefiles.com/packages/lf20_swnrn2oy.json',
        'gradient': const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const ManageCoursesScreen(),
      },
      {
        'title': 'Manage Updates',
        'lottieUrl':
            'https://assets5.lottiefiles.com/packages/lf20_qjosmr4w.json',
        'gradient': const LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const UpdatesManagementScreen(),
      },
      {
        'title': 'Manage Admissions',
        'lottieUrl':
            'https://assets3.lottiefiles.com/packages/lf20_DMgKk1.json',
        'gradient': const LinearGradient(
          colors: [Colors.pink, Colors.deepOrangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const AdminAdmissionsScreen(),
      },
      {
        'title': 'Manage About Me',
        'lottieUrl':
            'https://assets5.lottiefiles.com/packages/lf20_v1yudlrx.json',
        'gradient': const LinearGradient(
          colors: [Colors.indigo, Colors.cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const ManageAboutMeScreen(),
      },
      {
        'title': 'Manage Banner',
        'lottieUrl':
            'https://assets9.lottiefiles.com/packages/lf20_vvqbbhqg.json',
        'gradient': const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const ManageBannerScreen(),
      },
      {
        'title': 'Manage Enrollment',
        'lottieUrl':
            'https://assets3.lottiefiles.com/packages/lf20_5tl1xxnz.json',
        'gradient': const LinearGradient(
          colors: [Colors.teal, Colors.cyan],
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
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Welcome, SANI',
                      style: theme.textTheme.headlineMedium,
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
                  childAspectRatio: 1.3,
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
