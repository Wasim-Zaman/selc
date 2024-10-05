import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/admission_announcement.dart';
import 'package:selc/utils/constants.dart';
import 'dart:math';

import 'package:selc/view/widgets/placeholder_widget.dart';

class AdmissionsScreen extends StatelessWidget {
  const AdmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminCubit = context.read<AdminCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Admissions', style: theme.textTheme.headlineSmall),
      ),
      body: StreamBuilder<List<AdmissionAnnouncement>>(
        stream: adminCubit.getAdmissionAnnouncementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // placeholder
            return PlaceholderWidgets.cardPlaceholder();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No announcements available'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return AnnouncementCard(announcement: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}

class AnnouncementCardPlaceholder extends StatelessWidget {
  const AnnouncementCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 200, // Adjust the height as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                height: 24,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Container(
                width: 150,
                height: 16,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 16,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 40,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
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
