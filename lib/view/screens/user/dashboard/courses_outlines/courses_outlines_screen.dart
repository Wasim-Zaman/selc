import 'package:flutter/material.dart';
import 'dart:math';

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
        title: const Text(
          'Courses & Outlines',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
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
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.brown,
    ];
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
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: _singleColorGradient(),
        ),
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
    );
  }
}

class WeekExpansionPanel extends StatelessWidget {
  final Week week;

  const WeekExpansionPanel({Key? key, required this.week}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
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
