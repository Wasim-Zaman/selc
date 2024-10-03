// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc/providers/theme_provider.dart';
import 'package:selc/services/auth/auth_admin_service.dart';
import 'package:selc/view/screens/admin/dashboard/notes/admin_notes_categories_screen.dart';
import 'package:selc/view/widgets/grid_item.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AdminAuthService _authService = AdminAuthService();
    final themeProvider = Provider.of<ThemeProvider>(context);

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
        'screen': const AdminNotesCategoriesScreen(),
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
            ListTile(
              title: Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
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
