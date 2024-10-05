import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selc/models/course_outline.dart';

class CoursesOutlineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'courses_outlines';

  Stream<List<Course>> getCoursesStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        List<Week> weeks = (data['weeks'] as List).map((weekData) {
          return Week(
            title: weekData['title'],
            topics: List<String>.from(weekData['topics']),
          );
        }).toList();

        return Course(
          id: doc.id,
          title: data['title'],
          weeks: weeks,
        );
      }).toList();
    });
  }

  Future<void> addCourse(Course course) async {
    await _firestore.collection(_collection).add({
      'title': course.title,
      'weeks': course.weeks
          .map((week) => {
                'title': week.title,
                'topics': week.topics,
              })
          .toList(),
    });
  }

  Future<void> updateCourse(String courseId, Course course) async {
    await _firestore.collection(_collection).doc(courseId).update({
      'title': course.title,
      'weeks': course.weeks
          .map((week) => {
                'title': week.title,
                'topics': week.topics,
              })
          .toList(),
    });
  }

  Future<void> deleteCourse(String courseId) async {
    await _firestore.collection(_collection).doc(courseId).delete();
  }
}
