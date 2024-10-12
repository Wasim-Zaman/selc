import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selc/models/enrolled_students.dart';
import 'package:selc/services/analytics/analytics_service.dart';
import 'package:selc/services/enrolled_students/enrolled_students_services.dart';
import 'package:selc/view/widgets/placeholder_widget.dart';

class EnrolledStudentsScreen extends StatelessWidget {
  final EnrolledStudentsServices _enrolledStudentsServices =
      EnrolledStudentsServices(AnalyticsService());

  EnrolledStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Students'),
      ),
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(student.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('Level: ${student.level}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Text('Enrolled: ${student.enrollmentDate.year}',
                      style: Theme.of(context).textTheme.bodySmall),
                  onTap: () => _showStudentDetails(context, student),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showStudentDetails(BuildContext context, EnrolledStudent student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Contact Number: ${student.contactNumber}'),
            Text('Level: ${student.level}'),
            Text(
                'Enrolled: ${DateFormat('dd/MM/yyyy').format(student.enrollmentDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
