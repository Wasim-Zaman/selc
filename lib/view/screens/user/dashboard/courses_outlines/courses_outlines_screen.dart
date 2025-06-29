import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/course_outline.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/view/widgets/placeholder_widget.dart';

class CoursesOutlinesScreen extends StatelessWidget {
  const CoursesOutlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses & Outlines',
            style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: StreamBuilder<List<Course>>(
        stream: context.read<AdminCubit>().getCoursesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PlaceholderWidgets.listPlaceholder();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return CourseExpansionPanel(course: snapshot.data![index]);
            },
          );
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
        baseColor.withValues(alpha: 0.7),
        baseColor.withValues(alpha: 0.9),
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
            fontWeight: FontWeight.w600,
          ),
        ),
        children: week.topics.map((topic) {
          return ListTile(
            title: Text(topic),
            leading: const Icon(
              Icons.check_circle_outline,
              size: AppConstants.defaultIconSize,
            ),
          );
        }).toList(),
      ),
    );
  }
}
