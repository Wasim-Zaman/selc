// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/screens/user/dashboard/about_me/youtube_channel_screen.dart';
import 'package:selc/view/widgets/grid_item.dart'; // Import the GridItem widget
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  IconData getFallbackIcon(String title) {
    switch (title) {
      case 'Institute Location':
        return Icons.location_on;
      case 'YouTube Channel':
        return Icons.play_circle;
      default:
        return Icons.dashboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('About Me', style: theme.textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.deepOrange,
                      Colors.orange,
                      Colors.amber,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'John Doe',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Software Developer',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return GridItem(
                    title: gridItems[index]['title'],
                    screen: gridItems[index]['screen'],
                    gradient: const LinearGradient(
                      colors: [
                        Colors.deepPurple,
                        Colors.purple,
                        Colors.pink,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    lottieUrl: gridItems[index]['lottieUrl'],
                    onTap: gridItems[index]['onTap'],
                    fallbackIcon: getFallbackIcon(gridItems[index]['title']),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                color: theme.cardColor,
                child: Center(
                  child: Text(
                    'Google Map Placeholder',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                color: theme.cardColor,
                child: Center(
                  child: Text(
                    'PDF Resume Placeholder',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Updated grid items data with Lottie URLs and onTap functions
final List<Map<String, dynamic>> gridItems = [
  {
    'title': 'Institute Location',
    'lottieUrl': 'https://assets3.lottiefiles.com/packages/lf20_UJNc2t.json',
    'onTap': (BuildContext context) async {
      try {
        const double latitude = 37.4220;
        const double longitude = -122.0841;
        final Uri url = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          TopSnackbar.info(context, "Could not open the map");
        }
      } catch (e) {
        print('Error launching map: $e');
        TopSnackbar.error(context, "An error occurred while opening the map");
      }
    },
  },
  {
    'title': 'YouTube Channel',
    'lottieUrl':
        'https://assets4.lottiefiles.com/private_files/lf30_bb9bkg1h.json',
    'screen': const YouTubeChannelScreen(),
  },
];
