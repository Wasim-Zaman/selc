import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:selc/view/screens/user/dashboard/about_me/youtube_channel_screen.dart';
import 'package:selc/view/widgets/grid_item.dart'; // Import the GridItem widget

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  Future<void> _launchMaps() async {
    // Replace these with your institute's coordinates
    const double latitude = 37.4220;
    const double longitude = -122.0841;
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
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
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.colorScheme.secondary],
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
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Software Developer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
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
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    lottieUrl: gridItems[index]['lottieUrl'],
                    fallbackIcon: Icons.dashboard,
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
      const double latitude = 37.4220; // Replace with your institute's latitude
      const double longitude =
          -122.0841; // Replace with your institute's longitude
      final Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the map')),
        );
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
