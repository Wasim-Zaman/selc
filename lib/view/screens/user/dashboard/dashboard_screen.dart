// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/cubits/banner/banner_cubit.dart';
import 'package:selc/cubits/theme/theme_cubit.dart';
import 'package:selc/models/enrolled_students.dart';
import 'package:selc/services/analytics/analytics_service.dart';
import 'package:selc/services/auth/auth_service.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/admin/auth/admin_login_screen.dart';
import 'package:selc/view/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';
import 'package:selc/view/screens/user/dashboard/about_me/about_me_screen.dart';
import 'package:selc/view/screens/user/dashboard/admissions/admissions_screen.dart';
import 'package:selc/view/screens/user/dashboard/courses_outlines/courses_outlines_screen.dart';
import 'package:selc/view/screens/user/dashboard/enrolled_students/enrolled_students_screen.dart';
import 'package:selc/view/screens/user/dashboard/notes/notes_categories_screen.dart';
import 'package:selc/view/screens/user/dashboard/playlists/playlists_screen.dart';
import 'package:selc/view/screens/user/dashboard/terms_and_conditions_screen.dart';
import 'package:selc/view/screens/user/dashboard/updates/updates_screen.dart';
import 'package:selc/view/widgets/banner_slider.dart';
import 'package:selc/view/widgets/grid_item.dart';
import 'package:selc/view/widgets/learning_resources_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isAdminLoggedIn = false;
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await _analyticsService.logScreenView('Dashboard');
    _isAdminLoggedIn = await context.read<AuthCubit>().isAdminLoggedIn();
  }

  // Services data with icons and gradients
  final List<Map<String, dynamic>> services = [
    {
      'title': 'Notes',
      'lottieUrl': AppLotties.notes,
      'gradient': const LinearGradient(
        colors: [Color(0xFF6A1B9A), Color(0xFF1E88E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': NotesCategoriesScreen(),
    },
    {
      'title': 'Playlists',
      'lottieUrl': AppLotties.playlist,
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFE91E63)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const PlaylistsScreen(),
    },
    {
      'title': 'Courses &\nOutlines',
      'lottieUrl': AppLotties.courses,
      'gradient': const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF3F51B5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const CoursesOutlinesScreen(),
    },
    {
      'title': 'Updates',
      'lottieUrl': AppLotties.updates,
      'gradient': const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF009688)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const UpdatesScreen(),
    },
    {
      'title': 'Admissions',
      'lottieUrl': AppLotties.admissions,
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF4081), Color(0xFFFF5722)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const AdmissionsScreen(),
    },
    {
      'title': 'Enrolled\nStudents',
      'lottieUrl': AppLotties.students,
      'gradient': const LinearGradient(
        colors: [Color(0xFFFFA000), Color(0xFFFF5722)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': EnrolledStudentsScreen(),
    },
    {
      'title': 'About Me',
      'lottieUrl': AppLotties.aboutMe,
      'gradient': const LinearGradient(
        colors: [Color(0xFF3F51B5), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const AboutMeScreen(),
    },
    {
      'title': 'Terms &\nConditions',
      'lottieUrl': AppLotties.terms,
      'gradient': const LinearGradient(
        colors: [Color(0xFF009688), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const TermsAndConditionsScreen(),
    },
  ];

  IconData getFallbackIcon(String title) {
    switch (title) {
      case 'Notes':
        return Icons.note;
      case 'Playlists':
        return Icons.playlist_play;
      case 'Courses &\nOutlines':
        return Icons.book;
      case 'Updates':
        return Icons.update;
      case 'Admissions':
        return Icons.person_add;
      case 'About Me':
        return Icons.person;
      case 'Enrolled\nStudents':
        return Icons.school;
      case 'Terms &\nConditions':
        return Icons.description;
      default:
        return Icons.dashboard;
    }
  }

  Widget _buildDrawer() {
    final user = AuthService().getCurrentUser();
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Guest'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                user?.photoURL ?? 'https://via.placeholder.com/150',
              ),
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // Add profile navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Panel'),
            onTap: () {
              Navigator.pop(context);
              if (_isAdminLoggedIn) {
                Navigations.pushReplacement(
                    context, const AdminDashboardScreen());
              } else {
                Navigations.pushReplacement(context, const AdminLoginScreen());
              }
            },
          ),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeMode) {
              return ListTile(
                leading: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                title: Text(
                  themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
                ),
                onTap: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthCubit>().logout();
              Navigations.pushAndRemoveUntil(context, const LoginScreen());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().getCurrentUser();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Welcome Card and Controls
              _buildHeader(user, theme),

              // Banner Slider
              BlocProvider(
                create: (context) => BannerCubit(
                  bannersStream: context.read<AdminCubit>().getBannersStream(),
                ),
                child: const BannerSlider(),
              ),

              // Activity Graph
              _buildEnrollmentGraph(),

              // Services Grid
              _buildServicesGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User? user, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu and Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.displayName ?? 'Guest'}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Welcome to SELC!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyLarge?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Theme Switch and Profile
                Row(
                  children: [
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
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(
                        user?.photoURL ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_isAdminLoggedIn) ...[
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Switch to Admin Dashboard'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigations.pushReplacement(context, AdminDashboardScreen());
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    // Learning Resources section
    final learningResources = [
      services[0], // Notes
      services[1], // Playlists
      services[2], // Courses & Outlines
      services[3], // Updates
    ];

    // Information & Support section
    final informationSupport = [
      services[4], // Admissions
      services[5], // Enrolled Students
      services[6], // About Me
      services[7], // Terms & Conditions
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Learning Resources Section with horizontal scroll
        LearningResourcesSection(resources: learningResources),

        // Information & Support Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Information & Support',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: informationSupport.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  return GridItem(
                    title: informationSupport[index]['title'],
                    lottieUrl: informationSupport[index]['lottieUrl'],
                    gradient: informationSupport[index]['gradient'],
                    screen: informationSupport[index]['screen'],
                    fallbackIcon:
                        getFallbackIcon(informationSupport[index]['title']),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollmentGraph() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black26),
              left: BorderSide(color: Colors.black26),
              right: BorderSide(color: Colors.black26),
              bottom: BorderSide(color: Colors.black26),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Students Enrollment',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.15,
                child: StreamBuilder<List<EnrolledStudent>>(
                  stream:
                      context.read<AdminCubit>().getEnrolledStudentsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final enrollmentData = _getEnrollmentData(snapshot.data!);
                    final maxY = enrollmentData
                        .map((spot) => spot.y)
                        .reduce((a, b) => a > b ? a : b);

                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY + 2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                rod.toY.round().toString(),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun',
                                  'Jul',
                                  'Aug',
                                  'Sep',
                                  'Oct',
                                  'Nov',
                                  'Dec'
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      months[value.toInt()],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: enrollmentData.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.y,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.7),
                                    Theme.of(context).primaryColor,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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

  List<FlSpot> _getEnrollmentData(List<EnrolledStudent> students) {
    final enrollmentCounts = List.filled(6, 0);
    final currentYear = DateTime.now().year;

    for (var student in students) {
      if (student.enrollmentDate.year == currentYear) {
        final month = student.enrollmentDate.month - 1;
        if (month < 6) {
          enrollmentCounts[month]++;
        }
      }
    }

    return List.generate(
      6,
      (index) => FlSpot(index.toDouble(), enrollmentCounts[index].toDouble()),
    );
  }
}
