// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:selc/models/enrolled_students.dart';
import 'package:selc/router/app_navigation.dart';
import 'package:selc/router/app_routes.dart';
import 'package:selc/services/enrolled_students/enrolled_students_services.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';

class StudentsListTab extends StatelessWidget {
  final EnrolledStudentsServices enrolledStudentsServices;

  const StudentsListTab({super.key, required this.enrolledStudentsServices});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<EnrolledStudent>>(
      stream: enrolledStudentsServices.getEnrolledStudentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final students = snapshot.data ?? [];

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No students available',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _addStudent(context),
                  child: const Text('Add New Student'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: ListView.separated(
            itemCount: students.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final student = students[index];
              return Container(
                margin: const EdgeInsets.only(top: 5),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(student.name[0])),
                    title: Text(
                      student.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      student.level,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: theme.colorScheme.primary),
                          onPressed: () => _editStudent(context, student),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: theme.colorScheme.error),
                          onPressed: () => _confirmDelete(context, student),
                        ),
                      ],
                    ),
                    onTap: () => _showStudentDetails(context, student),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addStudent(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _editStudent(BuildContext context, EnrolledStudent student) async {
    final result = await AppNavigation.pushForResult<bool>(
        context, AppRoutes.kEditStudentRoute,
        extra: {
          'student': student,
          'enrolledStudentsServices': enrolledStudentsServices,
        });

    if (result == true) {
      TopSnackbar.success(context, 'Student updated successfully');
    }
  }

  void _showStudentDetails(BuildContext context, EnrolledStudent student) {
    AppNavigation.push(context, AppRoutes.kStudentDetailsRoute, extra: student);
  }

  void _addStudent(BuildContext context) async {
    final result = await AppNavigation.pushForResult<bool>(
        context, AppRoutes.kAddStudentRoute,
        extra: enrolledStudentsServices);

    if (result == true) {
      TopSnackbar.success(context, 'Student added successfully');
    }
  }

  void _confirmDelete(BuildContext context, EnrolledStudent student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await enrolledStudentsServices.deleteStudent(student.id);
        TopSnackbar.success(context, 'Student deleted successfully');
      } catch (e) {
        TopSnackbar.error(context, 'Error deleting student: $e');
      }
    }
  }
}
