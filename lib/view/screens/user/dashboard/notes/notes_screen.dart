import 'dart:math';

import 'package:flutter/material.dart';
import 'package:selc/utils/constants.dart'; // Import AppColors

class NotesScreen extends StatelessWidget {
  // List of note categories
  final List<String> categories = [
    'Parts of Speech',
    'Grammar',
    'Active Passive',
    'Tenses',
    'Direct & Indirect Speech',
    'Punctuation',
    'Vocabulary',
    'Writing Skills',
    'Reading Comprehension',
  ];

  NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return CategoryCard(category: categories[index]);
          },
        ),
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
    final colors = [
      AppColors.lightPrimary,
      AppColors.lightAccent,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.brown,
    ];
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
