import 'dart:math';

import 'package:flutter/material.dart';
import 'package:selc/utils/constants.dart';

class CoursesOutlinesScreen extends StatelessWidget {
  const CoursesOutlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Course> _courses = [
      // Keep the existing course data
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Courses & Outlines',
            style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          return CourseExpansionPanel(course: _courses[index]);
        },
      ),
    );
  }
}

class CourseExpansionPanel extends StatelessWidget {
  final Course course;

  const CourseExpansionPanel({super.key, required this.course});

  LinearGradient _singleColorGradient() {
    final random = Random();
    final baseColor =
        AppColors.randomColors[random.nextInt(AppColors.randomColors.length)];
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
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      elevation: AppConstants.defaultElevation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          gradient: _singleColorGradient(),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              course.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.lightAppBarForeground,
                fontSize: 18,
              ),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: course.weeks.length,
                itemBuilder: (context, index) {
                  return WeekExpansionPanel(week: course.weeks[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeekExpansionPanel extends StatelessWidget {
  final Week week;

  const WeekExpansionPanel({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          week.title,
          style: const TextStyle(
            color: AppColors.lightAppBarForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: week.topics.map((topic) {
          return ListTile(
            title: Text(
              topic,
              style: const TextStyle(color: AppColors.lightBodyText),
            ),
            leading: const Icon(Icons.check_circle_outline,
                size: AppConstants.defaultIconSize, color: AppColors.lightIcon),
          );
        }).toList(),
      ),
    );
  }
}

class Course {
  final String title;
  final List<Week> weeks;

  Course({required this.title, required this.weeks});
}

class Week {
  final String title;
  final List<String> topics;

  Week({required this.title, required this.topics});
}
