import 'dart:math';

import 'package:flutter/material.dart';
import 'package:selc/utils/constants.dart';

class CoursesOutlinesScreen extends StatelessWidget {
  const CoursesOutlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Course> _courses = [
      Course(
        title: '45 Days English Learning Course',
        weeks: [
          Week(
            title: 'Week 1',
            topics: [
              'Introduction to Basic Grammar',
              'Vocabulary Building: Common Words',
              'Simple Present Tense',
              'Basic Conversation Practice',
            ],
          ),
          Week(
            title: 'Week 2',
            topics: [
              'Past Simple Tense',
              'Reading Comprehension: Short Stories',
              'Listening Skills: Daily Dialogues',
              'Writing: Personal Introduction',
            ],
          ),
          // Add more weeks as needed
        ],
      ),
      Course(
        title: '30 Days Business English Course',
        weeks: [
          Week(
            title: 'Week 1',
            topics: [
              'Business Vocabulary Essentials',
              'Email Writing Fundamentals',
              'Professional Introductions',
              'Basic Business Phone Etiquette',
            ],
          ),
          Week(
            title: 'Week 2',
            topics: [
              'Presentation Skills Basics',
              'Business Report Writing',
              'Negotiation Language',
              'Networking Phrases and Small Talk',
            ],
          ),
          // Add more weeks as needed
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses & Outlines'),
      ),
      body: ListView.builder(
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
    const colors = AppColors.randomColors;
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
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
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
                color: Colors.white,
              ),
            ),
            children: course.weeks.map((week) {
              return WeekExpansionPanel(week: week);
            }).toList(),
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
          style: const TextStyle(color: Colors.white),
        ),
        children: week.topics.map((topic) {
          return ListTile(
            title: Text(
              topic,
              style: const TextStyle(color: Colors.white),
            ),
            leading: const Icon(Icons.circle, size: 10, color: Colors.white),
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
