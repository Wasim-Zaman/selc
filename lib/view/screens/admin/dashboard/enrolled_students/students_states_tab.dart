import 'package:flutter/material.dart';
import 'package:selc/services/enrolled_students/enrolled_students_services.dart';
import 'package:selc/models/enrolled_students.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:selc/view/screens/admin/dashboard/enrolled_students/student_details_screen.dart';
import 'package:selc/view/widgets/placeholder_widget.dart';

class StudentsStatsTab extends StatelessWidget {
  final EnrolledStudentsServices enrolledStudentsServices;

  const StudentsStatsTab({super.key, required this.enrolledStudentsServices});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EnrolledStudent>>(
      future: _getCurrentYearStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PlaceholderWidgets.studentsStatsTabPlaceholder();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final currentYearStudents = snapshot.data ?? [];
        final totalStudents = currentYearStudents.length;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Year Students',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalStudents',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enrollment Trend',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: _buildEnrollmentGraph(currentYearStudents),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Enrolled Students',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final student = currentYearStudents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(student.name[0].toUpperCase()),
                      ),
                      title: Text(student.name),
                      subtitle: Text(
                          'Enrolled: ${_formatDate(student.enrollmentDate)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StudentDetailsScreen(student: student),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: currentYearStudents.length,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        );
      },
    );
  }

  Widget _buildEnrollmentGraph(List<EnrolledStudent> students) {
    final enrollmentData = _getMonthlyEnrollmentData(students);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec'
                  ];
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Text(months[value.toInt()]);
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: enrollmentData
              .reduce((max, point) => point.y > max.y ? point : max)
              .y,
          lineBarsData: [
            LineChartBarData(
              spots: enrollmentData,
              isCurved: true,
              color: Colors.blue,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getMonthlyEnrollmentData(List<EnrolledStudent> students) {
    final enrollmentCounts = List.filled(12, 0);
    for (var student in students) {
      try {
        final enrollmentDate =
            DateTime.parse(student.enrollmentDate.toString());
        enrollmentCounts[enrollmentDate.month - 1]++;
      } catch (e) {
        print(
            'Invalid date for student ${student.name}: ${student.enrollmentDate}');
      }
    }
    return List.generate(
        12,
        (index) =>
            FlSpot(index.toDouble(), enrollmentCounts[index].toDouble()));
  }

  Future<List<EnrolledStudent>> _getCurrentYearStudents() async {
    final currentYear = DateTime.now().year;
    return await enrolledStudentsServices.getStudentsByYear(currentYear);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
