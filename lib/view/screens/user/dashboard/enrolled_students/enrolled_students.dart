import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selc/models/enrolled_students.dart';
import 'package:selc/services/analytics/analytics_service.dart';
import 'package:selc/services/enrolled_students/enrolled_students_services.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/view/widgets/placeholder_widget.dart';

class EnrolledStudentsScreen extends StatelessWidget {
  final EnrolledStudentsServices _enrolledStudentsServices =
      EnrolledStudentsServices(AnalyticsService());

  EnrolledStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrolled Students')),
      body: StreamBuilder<List<EnrolledStudent>>(
        stream: _enrolledStudentsServices.getEnrolledStudentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PlaceholderWidgets.listPlaceholder(itemCount: 10);
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final students = snapshot.data ?? [];

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentCard(context, student, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(
      BuildContext context, EnrolledStudent student, int index) {
    final theme = Theme.of(context);
    final initials = _getInitials(student.name);
    final color = AppColors.randomColors[index % AppColors.randomColors.length];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showStudentDetails(context, student),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color,
                child: Text(
                  initials,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level: ${student.level}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enrolled: ${DateFormat('MMM d, yyyy').format(student.enrollmentDate)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, min(2, name.length)).toUpperCase();
    }
  }

  void _showStudentDetails(BuildContext context, EnrolledStudent student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildStudentDetailsContent(context, student),
        );
      },
    );
  }

  Widget _buildStudentDetailsContent(
      BuildContext context, EnrolledStudent student) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
            top: 100,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightAppBarBackground
                : AppColors.darkAppBarBackground,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                student.name,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24.0),
              _buildDetailRow(Icons.school, 'Level', student.level),
              _buildDetailRow(Icons.email, 'Email', student.email),
              _buildDetailRow(
                  Icons.person, 'Father\'s Name', student.fatherName),
              _buildDetailRow(Icons.phone, 'Contact', student.contactNumber),
              _buildDetailRow(Icons.calendar_today, 'Enrolled',
                  DateFormat('MMM d, yyyy').format(student.enrollmentDate)),
              const SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 50,
            child: Text(
              _getInitials(student.name),
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Builder(
              builder: (BuildContext context) {
                final theme = Theme.of(context);
                final isLightMode = theme.brightness == Brightness.light;
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$label: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isLightMode
                              ? AppColors.lightBodyText
                              : AppColors.darkBodyText,
                        ),
                      ),
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          color: isLightMode
                              ? AppColors.lightBodyTextSecondary
                              : AppColors.darkBodyTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
