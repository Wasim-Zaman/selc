import 'dart:math';

import 'package:flutter/material.dart';
import 'package:selc/services/notes/notes_service.dart';
import 'package:selc/utils/constants.dart';

class NotesScreen extends StatelessWidget {
  final NotesService _notesService = NotesService();

  NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes', style: theme.textTheme.headlineSmall),
      ),
      body: StreamBuilder<List<String>>(
        stream: _notesService.getCategoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return CategoryCard(category: snapshot.data![index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String category;

  const CategoryCard({super.key, required this.category});

  // Function to generate a gradient with different shades of the same color
  LinearGradient _singleColorGradient() {
    final random = Random();
    const colors = AppColors.randomColors;
    final baseColor = colors[random.nextInt(colors.length)];
    return LinearGradient(
      colors: [
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.9),
        baseColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: _singleColorGradient(),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Handle category tap
            // You can navigate to a detailed notes screen for each category
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
