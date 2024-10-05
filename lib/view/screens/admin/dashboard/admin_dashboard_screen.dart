import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/cubits/theme/theme_cubit.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/admin/dashboard/admissions/admin_admissions.dart';
import 'package:selc/view/screens/admin/dashboard/courses_outlines/manage_courses_screen.dart';
import 'package:selc/view/screens/admin/dashboard/notes/admin_notes_categories_screen.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';
import 'package:selc/view/screens/user/dashboard/dashboard_screen.dart';
import 'package:selc/view/widgets/grid_item.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Admin services data with icons and gradients
    final List<Map<String, dynamic>> adminServices = [
      {
        'title': 'Manage Notes',
        'icon': Icons.note,
        'gradient': const LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': AdminNotesCategoriesScreen(),
      },
      {
        'title': 'Manage Playlists',
        'icon': Icons.playlist_play,
        'gradient': const LinearGradient(
          colors: [Colors.orange, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Manage Courses',
        'icon': Icons.school,
        'gradient': const LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const ManageCoursesScreen(),
      },
      {
        'title': 'Manage Updates',
        'icon': Icons.update,
        'gradient': const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Manage Admissions',
        'icon': Icons.person_add,
        'gradient': const LinearGradient(
          colors: [Colors.pink, Colors.deepOrangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'screen': const AdminAdmissionsScreen(),
      },
      {
        'title': 'Analytics',
        'icon': Icons.analytics,
        'gradient': const LinearGradient(
          colors: [Colors.indigo, Colors.cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: theme.textTheme.headlineSmall),
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
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return ListTile(
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: state.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                );
              },
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
            // ... other drawer items
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Admin',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge,
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
                    icon: adminServices[index]['icon'],
                    gradient: adminServices[index]['gradient'],
                    screen: adminServices[index]['screen'],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Activity',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text('Activity ${index + 1}'),
                      subtitle: Text('Description of activity ${index + 1}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
