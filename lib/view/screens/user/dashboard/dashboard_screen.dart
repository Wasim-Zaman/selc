import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isAdminLoggedIn = false;

  // First two entries are promoted to the "featured" quick-action cards;
  // the rest render in the compact grid below.
  static const List<_Service> _services = [
    _Service(
      'Notes',
      AppLotties.notes,
      AppRoutes.kNotesCategoriesRoute,
      AppGradients.notes,
      subtitle: 'Browse subject-wise notes',
      icon: Icons.menu_book_rounded,
    ),
    _Service(
      'Courses',
      AppLotties.courses,
      AppRoutes.kCoursesOutlinesRoute,
      AppGradients.courses,
      subtitle: 'Explore course outlines',
      icon: Icons.school_rounded,
    ),
    _Service(
      'Updates',
      AppLotties.updates,
      AppRoutes.kUpdatesRoute,
      AppGradients.updates,
      icon: Icons.campaign_rounded,
    ),
    _Service(
      'Admissions',
      AppLotties.admissions,
      AppRoutes.kAdmissionsRoute,
      AppGradients.admissions,
      icon: Icons.badge_rounded,
    ),
    _Service(
      'Students',
      AppLotties.students,
      AppRoutes.kEnrolledStudentsRoute,
      AppGradients.students,
      icon: Icons.groups_rounded,
    ),
    _Service(
      'About',
      AppLotties.aboutMe,
      AppRoutes.kAboutMeRoute,
      AppGradients.aboutMe,
      icon: Icons.info_rounded,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().getCurrentUser();
    final featured = _services.take(2).toList();
    final rest = _services.skip(2).toList();

    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
        debugDisplayAlways: true,
        minAppVersion: '1.0.0',
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(isAdminLoggedIn: _isAdminLoggedIn),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(user, theme)),

              // Banner Slider
              SliverToBoxAdapter(
                child: BlocProvider(
                  create: (context) => BannerCubit(
                    bannersStream: context
                        .read<AdminCubit>()
                        .getBannersStream(),
                  ),
                  child: const BannerSlider(),
                ).animate().fadeIn(duration: 350.ms),
              ),

              // Quick Actions — featured
              const SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.bolt_rounded,
                  title: 'Quick Actions',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      for (var i = 0; i < featured.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(
                          child: _FeaturedActionCard(
                            service: featured[i],
                            index: i,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Explore — remaining services
              const SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.apps_rounded,
                  title: 'Explore',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 96,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _ServiceTile(service: rest[index], index: index),
                    childCount: rest.length,
                  ),
                ),
              ),

              // Enrollment Insight
              const SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.insights_rounded,
                  title: 'Enrollment Insight',
                ),
              ),
              SliverToBoxAdapter(
                child: const _InsightCard()
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.05, end: 0),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User? user, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final firstName =
        (user?.displayName?.split(' ').first.trim().isNotEmpty ?? false)
        ? user!.displayName!.split(' ').first
        : 'Guest';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF00E5FF), const Color(0xFF7C4DFF)]
                    : [colorScheme.primary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $firstName 👋',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Welcome back to GEP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final isLight = state.themeMode == ThemeMode.light;
              return _HeaderIconButton(
                icon: isLight
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                isDark: isDark,
                onTap: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF00E5FF), const Color(0xFF7C4DFF)]
                          : [colorScheme.primary, colorScheme.tertiary],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user?.photoURL ?? '',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const Padding(
                          padding: EdgeInsets.all(9.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, _, _) => Icon(
                          Icons.person_outline,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Kept for admin-only entry point; surfaced inside the drawer/quick
  // actions context rather than the old inline banner.
  Widget adminSwitchBanner(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    if (!_isAdminLoggedIn) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => AppNavigation.pushReplacement(
            context,
            AppRoutes.kAdminDashboardRoute,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF7C4DFF).withValues(alpha: 0.12)
                  : colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF7C4DFF).withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 20,
                  color: isDark ? const Color(0xFF7C4DFF) : colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Switch to Admin Dashboard',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark
                        ? const Color(0xFF7C4DFF)
                        : colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF7C4DFF) : colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : colorScheme.surfaceContainerHigh,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 19),
        ),
      ),
    );
  }
}

class _Service {
  const _Service(
    this.title,
    this.lottie,
    this.route,
    this.gradient, {
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String lottie;
  final String route;
  final Gradient gradient;
  final String? subtitle;
  final IconData icon;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Large gradient "hero" action card — mirrors the two-up quick-action
/// layout, with a frosted circular chevron button and a Lottie glyph
/// tucked into the corner.
class _FeaturedActionCard extends StatelessWidget {
  const _FeaturedActionCard({required this.service, required this.index});

  final _Service service;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
          onTap: () async {
            await AnalyticsService().logButtonClick(service.title);
            if (context.mounted) AppNavigation.push(context, service.route);
          },
          child: Container(
            height: 148,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: service.gradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  bottom: -18,
                  child: Opacity(
                    opacity: 0.35,
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Lottie.asset(
                        service.lottie,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          service.icon,
                          size: 72,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_outward_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      service.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.subtitle ?? 'Open $service.title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 80).ms)
        .slideX(begin: index.isEven ? -0.06 : 0.06, end: 0);
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.index});

  final _Service service;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        await AnalyticsService().logButtonClick(service.title);
        if (context.mounted) AppNavigation.push(context, service.route);
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: service.gradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.cyan.withValues(alpha: 0.15)
                        : theme.colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Lottie.asset(
                  service.lottie,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      Icon(service.icon, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (80 + index * 40).ms).slideY(begin: 0.1, end: 0);
  }
}

/// Overview-style card: a headline enrollment count, a change badge
/// computed against last month, a sparkline, and three small stat chips
/// (total / this month / monthly average) driven entirely by the real
/// `EnrolledStudent` stream — no placeholder figures.
class _InsightCard extends StatelessWidget {
  const _InsightCard();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00E5FF) : colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      color: isDark ? const Color(0xFF16162A) : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<EnrolledStudent>>(
          stream: context.read<AdminCubit>().getEnrolledStudentsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            if (snapshot.hasError) {
              return const SizedBox(
                height: 180,
                child: Center(
                  child: Text('Unable to load enrollment data.'),
                ),
              );
            }

            final students = snapshot.data ?? [];
            final now = DateTime.now();
            final counts = List.filled(6, 0);
            for (final student in students) {
              if (student.enrollmentDate.year == now.year &&
                  student.enrollmentDate.month <= 6) {
                counts[student.enrollmentDate.month - 1]++;
              }
            }
            final spots = List.generate(
              6,
              (i) => FlSpot(i.toDouble(), counts[i].toDouble()),
            );
            final maxCount = counts.reduce((a, b) => a > b ? a : b);
            final maxY = (maxCount + 1).toDouble();

            final thisMonthIndex = now.month - 1;
            final thisMonthCount =
                (thisMonthIndex >= 0 && thisMonthIndex < 6)
                    ? counts[thisMonthIndex]
                    : 0;
            final lastMonthIndex = thisMonthIndex - 1;
            final lastMonthCount =
                (lastMonthIndex >= 0 && lastMonthIndex < 6)
                    ? counts[lastMonthIndex]
                    : 0;
            final change = lastMonthCount == 0
                ? (thisMonthCount == 0 ? 0.0 : 100.0)
                : ((thisMonthCount - lastMonthCount) / lastMonthCount) * 100;
            final monthsElapsed = now.month.clamp(1, 6);
            final avgPerMonth = counts
                    .take(monthsElapsed)
                    .fold<int>(0, (a, b) => a + b) /
                monthsElapsed;

            if (students.isEmpty) {
              return SizedBox(
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights_outlined,
                      size: 40,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No enrollments yet',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student data will appear here',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL ENROLLED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${students.length}',
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      change >= 0
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      size: 14,
                                      color: change >= 0
                                          ? Colors.greenAccent.shade400
                                          : Colors.redAccent.shade100,
                                    ),
                                    Text(
                                      '${change.abs().toStringAsFixed(0)}%',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                        color: change >= 0
                                            ? Colors.greenAccent.shade400
                                            : Colors.redAccent.shade100,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'vs last month',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 56,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 5,
                          minY: 0,
                          maxY: maxY,
                          lineTouchData:
                              const LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: accentColor,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.25),
                                    accentColor.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        label: 'This Month',
                        value: '$thisMonthCount',
                        progress:
                            maxCount == 0 ? 0 : thisMonthCount / maxCount,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatChip(
                        label: 'Avg / Month',
                        value: avgPerMonth.toStringAsFixed(1),
                        progress:
                            maxCount == 0 ? 0 : avgPerMonth / maxCount,
                        color: isDark
                            ? const Color(0xFF7C4DFF)
                            : colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatChip(
                        label: 'Peak Month',
                        value: maxCount == 0
                            ? '—'
                            : _months[counts.indexOf(maxCount)],
                        progress: 1,
                        color: Colors.orangeAccent.shade200,
                        showBar: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 20,
                  child: Row(
                    children: List.generate(_months.length, (i) {
                      final isCurrent = i == thisMonthIndex;
                      return Expanded(
                        child: Text(
                          _months[i],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isCurrent
                                ? accentColor
                                : (isDark
                                    ? Colors.white54
                                    : colorScheme.onSurfaceVariant),
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Small pill-style stat card used inside the Enrollment Insight card —
/// mirrors the "Active / Approved / Rejected" chip row from the reference
/// design, with an optional thin progress bar underneath.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    this.showBar = true,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;
  final bool showBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (showBar) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                minHeight: 4,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
