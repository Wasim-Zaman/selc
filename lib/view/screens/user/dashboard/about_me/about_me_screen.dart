import 'package:flutter/material.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/view/widgets/grid_item.dart'; // Import the GridItem widget

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Me'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section with personal details
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: const LinearGradient(
                    colors: [AppColors.lightPrimary, AppColors.lightAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Software Developer',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // GridView for additional information or features
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridItems.length, // Number of items in the grid
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return GridItem(
                    title: gridItems[index]['title'],
                    icon: gridItems[index]['icon'],
                    gradient: const LinearGradient(
                      colors: [AppColors.lightPrimary, AppColors.lightAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Placeholder for Google Map
              Container(
                height: 200,
                color: AppColors.darkAppBarBackground,
                child: const Center(
                  child: Text(
                    'Google Map Placeholder',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Placeholder for PDF Resume
              Container(
                height: 200,
                color: AppColors.darkAppBarBackground,
                child: const Center(
                  child: Text(
                    'PDF Resume Placeholder',
                    style: TextStyle(
                      fontSize: 16,
                    ),
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

// Grid items data
final List<Map<String, dynamic>> gridItems = [
  {
    'title': 'Institute Location',
    'icon': Icons.location_on,
  },
  {
    'title': 'YouTube Channel',
    'icon': Icons.video_library,
  },
];
