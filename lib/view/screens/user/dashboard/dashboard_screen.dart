// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/cubits/auth/auth_cubit.dart';
import 'package:selc/cubits/theme/theme_cubit.dart';
import 'package:selc/models/banner.dart';
import 'package:selc/services/auth/auth_service.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/admin/auth/admin_login_screen.dart';
import 'package:selc/view/screens/admin/dashboard/admin_dashboard_screen.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';
import 'package:selc/view/screens/user/dashboard/about_me/about_me_screen.dart';
import 'package:selc/view/screens/user/dashboard/admissions/admissions_screen.dart';
import 'package:selc/view/screens/user/dashboard/courses_outlines/courses_outlines_screen.dart';
import 'package:selc/view/screens/user/dashboard/notes/notes_categories_screen.dart';
import 'package:selc/view/screens/user/dashboard/playlists/playlists_screen.dart';
import 'package:selc/view/screens/user/dashboard/terms_and_conditions_screen.dart';
import 'package:selc/view/screens/user/dashboard/updates/updates_screen.dart';
import 'package:selc/view/widgets/grid_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Track the current page index for the carousel
  int _currentIndex = 0;
  bool _isAdminLoggedIn = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().isAdminLoggedIn().then((value) {
      setState(() {
        _isAdminLoggedIn = value;
      });
    });
  }

  // Services data with icons and gradients
  final List<Map<String, dynamic>> services = [
    {
      'title': 'Notes',
      'lottieUrl':
          'https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json',
      'gradient': const LinearGradient(
        colors: [Colors.purple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': NotesCategoriesScreen(),
    },
    {
      'title': 'Playlists',
      'lottieUrl':
          'https://assets9.lottiefiles.com/private_files/lf30_WdTEui.json',
      'gradient': const LinearGradient(
        colors: [Colors.orange, Colors.red],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const PlaylistsScreen(),
    },
    {
      'title': 'Courses &\nOutlines',
      'lottieUrl':
          'https://assets3.lottiefiles.com/packages/lf20_swnrn2oy.json',
      'gradient': const LinearGradient(
        colors: [Colors.blue, Colors.lightBlueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const CoursesOutlinesScreen(),
    },
    {
      'title': 'Updates',
      'lottieUrl':
          'https://assets5.lottiefiles.com/packages/lf20_qjosmr4w.json',
      'gradient': const LinearGradient(
        colors: [Colors.green, Colors.teal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const UpdatesScreen(),
    },
    {
      'title': 'Admissions',
      'lottieUrl': 'https://assets3.lottiefiles.com/packages/lf20_DMgKk1.json',
      'gradient': const LinearGradient(
        colors: [Colors.pink, Colors.deepOrangeAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const AdmissionsScreen(),
    },
    {
      'title': 'Enrolled\nStudents',
      'lottieUrl':
          'https://assets3.lottiefiles.com/packages/lf20_5tl1xxnz.json',
      'gradient': const LinearGradient(
        colors: [Colors.amber, Colors.orange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // 'screen': const EnrolledStudentsScreen(),
    },
    {
      'title': 'About Me',
      'lottieUrl':
          'https://assets5.lottiefiles.com/packages/lf20_v1yudlrx.json',
      'gradient': const LinearGradient(
        colors: [Colors.indigo, Colors.cyan],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const AboutMeScreen(),
    },
    {
      'title': 'Terms &\nConditions',
      'lottieUrl':
          'https://assets9.lottiefiles.com/packages/lf20_ysrn2iwp.json',
      'gradient': const LinearGradient(
        colors: [Colors.teal, Colors.cyan],
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminCubit = context.read<AdminCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  Text(AuthService().getCurrentUser()?.displayName ?? 'Guest'),
              accountEmail: Text(AuthService().getCurrentUser()?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  AuthService().getCurrentUser()?.photoURL ??
                      'https://via.placeholder.com/150',
                ),
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: theme.iconTheme.color),
              title: Text('Admin', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigations.pushAndRemoveUntil(
                  context,
                  _isAdminLoggedIn
                      ? const AdminDashboardScreen()
                      : const AdminLoginScreen(),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.iconTheme.color),
              title: Text('Sign Out', style: theme.textTheme.bodyLarge),
              onTap: () async {
                await AuthService().signOut();
                Navigations.pushAndRemoveUntil(context, const LoginScreen());
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: StreamBuilder<List<BannerModel>>(
                stream: adminCubit.getBannersStream(),
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return PlaceholderWidgets.bannerPlaceholder();
                  // } else
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          aspectRatio: 16 / 9,
                          initialPage: 0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        items: snapshot.data!.map((banner) {
                          return Builder(
                            builder: (BuildContext context) {
                              return CachedNetworkImage(
                                imageUrl: banner.imageUrl,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      Positioned(
                        bottom: 16,
                        child: AnimatedSmoothIndicator(
                          activeIndex: _currentIndex,
                          count: snapshot.data!.length,
                          effect: ExpandingDotsEffect(
                            dotHeight: 6,
                            dotWidth: 6,
                            dotColor: theme.colorScheme.secondary,
                            activeDotColor: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  return GridItem(
                    title: services[index]['title'],
                    lottieUrl: services[index]['lottieUrl'],
                    gradient: services[index]['gradient'],
                    screen: services[index]['screen'],
                    fallbackIcon: getFallbackIcon(
                      services[index]['title'],
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
}
