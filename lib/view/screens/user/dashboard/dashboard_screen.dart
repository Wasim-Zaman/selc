// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc/providers/theme_provider.dart';
import 'package:selc/services/auth/auth_service.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/admin/auth/admin_login_screen.dart';
import 'package:selc/view/screens/user/auth/login_screen.dart';
import 'package:selc/view/screens/user/dashboard/about_me/about_me_screen.dart';
import 'package:selc/view/screens/user/dashboard/admissions/admissions_screen.dart';
import 'package:selc/view/screens/user/dashboard/courses_outlines/courses_outlines_screen.dart';
import 'package:selc/view/screens/user/dashboard/notes/notes_categories_screen.dart';
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

  // Services data with icons and gradients
  final List<Map<String, dynamic>> services = [
    {
      'title': 'Notes',
      'icon': Icons.note,
      'gradient': const LinearGradient(
        colors: [Colors.purple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': NotesCategoriesScreen(),
    },
    {
      'title': 'Playlists',
      'icon': Icons.music_note,
      'gradient': const LinearGradient(
        colors: [Colors.orange, Colors.red],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Courses & \nOutlines',
      'icon': Icons.book,
      'gradient': const LinearGradient(
        colors: [Colors.green, Colors.teal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const CoursesOutlinesScreen(),
    },
    {
      'title': 'Updates',
      'icon': Icons.update,
      'gradient': const LinearGradient(
        colors: [Colors.blue, Colors.lightBlueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Admissions',
      'icon': Icons.school,
      'gradient': const LinearGradient(
        colors: [Colors.pink, Colors.deepOrangeAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const AdmissionsScreen(),
    },
    {
      'title': 'About Me',
      'icon': Icons.person,
      'gradient': const LinearGradient(
        colors: [Colors.indigo, Colors.cyan],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'screen': const AboutMeScreen(),
    },
  ];

  // Image URLs for carousel
  final List<String> imageUrls = [
    'https://khazar.org/uploads/files/eng_depart/eng.jpg',
    'https://yeapenglish.com/images/blog/4629725007-Ads%C4%B1z.png',
    'https://www.krmangalamgurgaon.com/wp-content/uploads/2023/12/25-G2-1024x576-1920x1080.webp',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: theme.textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
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
                  const AdminLoginScreen(),
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
              child: Stack(
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
                    items: imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return CachedNetworkImage(
                            imageUrl: url,
                            imageBuilder: (context, imageProvider) => Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
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
                      count: imageUrls.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 6,
                        dotWidth: 6,
                        dotColor: theme.colorScheme.secondary,
                        activeDotColor: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
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
                    icon: services[index]['icon'],
                    gradient: services[index]['gradient'],
                    screen: services[index]['screen'],
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
