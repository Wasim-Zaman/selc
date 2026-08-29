import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../core/constants/constants.dart';
import '../../../../cubits/admin/admin_cubit.dart';
import '../../../../cubits/auth/auth_cubit.dart';
import '../../../../cubits/banner/banner_cubit.dart';
import '../../../../cubits/theme/theme_cubit.dart';
import '../../../../models/enrolled_students.dart';
import '../../../../router/app_navigation.dart';
import '../../../../router/app_routes.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/banner_slider.dart';
import '../../../widgets/grid_item.dart';
import '../../../widgets/learning_resources_section.dart';

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
    if (!mounted) return;
    final isAdminLoggedIn = await context.read<AuthCubit>().isAdminLoggedIn();
    if (!mounted) return;
    setState(() => _isAdminLoggedIn = isAdminLoggedIn);
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
      'routeName': AppRoutes.kNotesCategoriesRoute,
    },
    {
      'title': 'Courses &\nOutlines',
      'lottieUrl': AppLotties.courses,
      'gradient': const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF3F51B5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'routeName': AppRoutes.kCoursesOutlinesRoute,
    },
    {
      'title': 'Updates',
      'lottieUrl': AppLotties.updates,
      'gradient': const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF009688)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'routeName': AppRoutes.kUpdatesRoute,
    },
    {
      'title': 'Admissions',
      'lottieUrl': AppLotties.admissions,
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF4081), Color(0xFFFF5722)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'routeName': AppRoutes.kAdmissionsRoute,
    },
    {
      'title': 'Enrolled\nStudents',
      'lottieUrl': AppLotties.students,
      'gradient': const LinearGradient(
        colors: [Color(0xFFFFA000), Color(0xFFFF5722)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'routeName': AppRoutes.kEnrolledStudentsRoute,
    },
    {
      'title': 'About Me',
      'lottieUrl': AppLotties.aboutMe,
      'gradient': const LinearGradient(
        colors: [Color(0xFF3F51B5), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'routeName': AppRoutes.kAboutMeRoute,
    },
    {
      'title': 'Terms &\nConditions',
      'lottieUrl': AppLotties.terms,
      'gradient': const LinearGradient(
        colors: [Color(0xFF009688), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'routeName': AppRoutes.kTermsAndConditionsRoute,
    },
  ];

  IconData getFallbackIcon(String title) {
    switch (title) {
      case 'Notes':
        return Icons.note;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().getCurrentUser();

    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
        debugDisplayAlways: true,
        minAppVersion: '1.0.0',
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(isAdminLoggedIn: _isAdminLoggedIn),
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
                          'Welcome to GEP!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Theme Switch and Profile
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: user?.photoURL ??
                              'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, state) {
                        return IconButton(
                          constraints:
                              const BoxConstraints(minWidth: 40, minHeight: 40),
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
              ],
            ),
            if (_isAdminLoggedIn) ...[
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Switch to Admin Dashboard'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  AppNavigation.pushReplacement(
                      context, AppRoutes.kAdminDashboardRoute);
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
      services[1], // Courses & Outlines
      services[2], // Updates
    ];

    // Information & Support section
    final informationSupport = [
      services[3], // Admissions
      services[4], // Enrolled Students
      services[5], // About Me
      services[6], // Terms & Conditions
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    routeName: informationSupport[index]['routeName'],
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
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
            left: BorderSide(color: Theme.of(context).dividerColor),
            right: BorderSide(color: Theme.of(context).dividerColor),
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
          borderRadius: BorderRadius.circular(15),
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
                stream: context.read<AdminCubit>().getEnrolledStudentsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final enrollmentData = _getEnrollmentData(snapshot.data!);
                  final maxY = enrollmentData
                      .map((spot) => spot.y)
                      .reduce((a, b) => a > b ? a : b);

                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

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
                              TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkBodyText
                                    : AppColors.lightBodyText,
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkBodyText
                                          : AppColors.lightBodyText,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkBodyText
                                      : AppColors.lightBodyText,
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
                            color: (isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider)
                                .withValues(alpha: 0.2),
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
                                      .withValues(alpha: 0.7),
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
