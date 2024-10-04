import 'dart:math';

import 'package:flutter/material.dart';
import 'package:selc/utils/constants.dart';

class AdmissionsScreen extends StatelessWidget {
  const AdmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sample admission announcements
    final List<AdmissionAnnouncement> announcements = [
      AdmissionAnnouncement(
        title: 'Fall 2023 Admissions',
        startDate: DateTime(2023, 8, 1),
        endDate: DateTime(2023, 9, 15),
        details: 'Applications are open for all undergraduate programs.',
      ),
      AdmissionAnnouncement(
        title: 'Spring 2024 Admissions',
        startDate: DateTime(2023, 12, 1),
        endDate: DateTime(2024, 1, 15),
        details: 'Limited seats available for graduate programs.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Admissions', style: theme.textTheme.headlineSmall),
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          return AnnouncementCard(announcement: announcements[index]);
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final AdmissionAnnouncement announcement;

  const AnnouncementCard({super.key, required this.announcement});

  LinearGradient _singleColorGradient() {
    final random = Random();
    const colors = AppColors.randomColors;
    final baseColor = colors[random.nextInt(colors.length)];
    return LinearGradient(
      colors: [
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _singleColorGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Application Period:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(announcement.startDate)} - ${_formatDate(announcement.endDate)}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                announcement.details,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add action for "Apply Now" button
                },
                child: const Text('Apply Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AdmissionAnnouncement {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String details;

  AdmissionAnnouncement({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.details,
  });
}
