import 'package:gep/models/course_outline.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoursesOutlineService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'courses_outlines';

  Stream<List<Course>> getCoursesStream() {
    return _supabase.from(_table).stream(primaryKey: ['id']).map((rows) {
      return rows.map((row) {
        List<Week> weeks = ((row['weeks'] as List?) ?? []).map((weekData) {
          return Week(
            title: weekData['title'],
            topics: List<String>.from(weekData['topics'] ?? []),
          );
        }).toList();

        return Course(
          id: row['id'] as String,
          title: row['title'],
          weeks: weeks,
        );
      }).toList();
    });
  }

  Future<void> addCourse(Course course) async {
    await _supabase.from(_table).insert(_toRow(course));
  }

  Future<void> updateCourse(String courseId, Course course) async {
    await _supabase.from(_table).update(_toRow(course)).eq('id', courseId);
  }

  Future<void> deleteCourse(String courseId) async {
    await _supabase.from(_table).delete().eq('id', courseId);
  }

  Map<String, dynamic> _toRow(Course course) => {
        'title': course.title,
        'weeks': course.weeks
            .map((week) => {
                  'title': week.title,
                  'topics': week.topics,
                })
            .toList(),
      };
}
