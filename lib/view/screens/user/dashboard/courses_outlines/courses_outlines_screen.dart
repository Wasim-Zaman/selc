import 'dart:math';

import 'package:flutter/material.dart';
import 'package:selc/models/course_outline.dart';
import 'package:selc/utils/constants.dart';

class CoursesOutlinesScreen extends StatelessWidget {
  const CoursesOutlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Course> courses = [
      Course(
        title: 'Introduction to English Grammar',
        weeks: [
          Week(
            title: 'Week 1: Parts of Speech',
            topics: [
              'Nouns',
              'Pronouns',
              'Verbs',
              'Adjectives',
              'Adverbs',
            ],
          ),
          Week(
            title: 'Week 2: Sentence Structure',
            topics: [
              'Subject and Predicate',
              'Simple Sentences',
              'Compound Sentences',
              'Complex Sentences',
            ],
          ),
          Week(
            title: 'Week 3: Tenses',
            topics: [
              'Present Tense',
              'Past Tense',
              'Future Tense',
              'Perfect Tenses',
            ],
          ),
        ],
      ),
      Course(
        title: 'Advanced English Composition',
        weeks: [
          Week(
            title: 'Week 1: Essay Structure',
            topics: [
              'Introduction',
              'Body Paragraphs',
              'Conclusion',
              'Thesis Statements',
            ],
          ),
          Week(
            title: 'Week 2: Rhetorical Strategies',
            topics: [
              'Ethos, Pathos, Logos',
              'Persuasive Writing',
              'Descriptive Writing',
              'Narrative Writing',
            ],
          ),
          Week(
            title: 'Week 3: Research and Citation',
            topics: [
              'Finding Credible Sources',
              'MLA Citation',
              'APA Citation',
              'Avoiding Plagiarism',
            ],
          ),
        ],
      ),
      Course(
        title: 'English Literature Survey',
        weeks: [
          Week(
            title: 'Week 1: Medieval Literature',
            topics: [
              'Beowulf',
              'The Canterbury Tales',
              'Sir Gawain and the Green Knight',
            ],
          ),
          Week(
            title: 'Week 2: Renaissance Literature',
            topics: [
              'Shakespeare\'s Sonnets',
              'Hamlet',
              'Paradise Lost',
            ],
          ),
          Week(
            title: 'Week 3: Romantic Poetry',
            topics: [
              'William Wordsworth',
              'Samuel Taylor Coleridge',
              'John Keats',
            ],
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Courses & Outlines',
            style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return CourseExpansionPanel(course: courses[index]);
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
