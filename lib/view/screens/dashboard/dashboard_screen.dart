import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  // Services data and their gradients
  final List<Map<String, dynamic>> services = [
    {
      'title': 'Notes',
      'gradient': const LinearGradient(
        colors: [Colors.purple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Playlists',
      'gradient': const LinearGradient(
        colors: [Colors.orange, Colors.red],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Courses & Outlines',
      'gradient': const LinearGradient(
        colors: [Colors.green, Colors.teal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Updates',
      'gradient': const LinearGradient(
        colors: [Colors.blue, Colors.lightBlueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'Admissions',
      'gradient': const LinearGradient(
        colors: [Colors.pink, Colors.deepOrangeAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'title': 'About Me',
      'gradient': const LinearGradient(
        colors: [Colors.indigo, Colors.cyan],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16.0, // Spacing between columns
            mainAxisSpacing: 16.0, // Spacing between rows
            childAspectRatio: 1.0, // Square items
          ),
          itemBuilder: (context, index) {
            return ServiceTile(
              title: services[index]['title'],
              gradient: services[index]['gradient'],
            );
          },
        ),
      ),
    );
  }
}

// Service Tile Widget
class ServiceTile extends StatelessWidget {
  final String title;
  final Gradient gradient;

  const ServiceTile({
    super.key,
    required this.title,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle on tap
        print('$title clicked!');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: gradient,
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
