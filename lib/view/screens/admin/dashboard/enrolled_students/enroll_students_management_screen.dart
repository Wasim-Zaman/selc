import 'package:flutter/material.dart';
import 'package:selc/services/enrolled_students/enrolled_students_services.dart';
import 'package:selc/view/screens/admin/dashboard/enrolled_students/students_list_tab_screen.dart';
import 'package:selc/view/screens/admin/dashboard/enrolled_students/students_states_tab.dart';

class EnrollStudentsManagementScreen extends StatelessWidget {
  final EnrolledStudentsServices _enrolledStudentsServices =
      EnrolledStudentsServices();

  EnrollStudentsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enrolled Students'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Students List'),
              Tab(text: 'Statistics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StudentsListTab(
                enrolledStudentsServices: _enrolledStudentsServices),
            StudentsStatsTab(
                enrolledStudentsServices: _enrolledStudentsServices),
          ],
        ),
      ),
    );
  }
}
