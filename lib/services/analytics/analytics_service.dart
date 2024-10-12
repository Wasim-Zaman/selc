import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logLogin(String loginMethod) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logButtonClick(String buttonName) async {
    await _analytics.logEvent(
      name: 'button_click',
      parameters: {'button_name': buttonName},
    );
  }

  // ? Student Enrollment Start
  Future<void> logStudentEnrollment(
      String studentName, String fatherName) async {
    await _analytics.logEvent(
      name: 'student_enrollment',
      parameters: {
        'student_name': studentName,
        'father_name': fatherName,
        'enrollment_date': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logStudentUpdate(String studentName, String fatherName) async {
    await _analytics.logEvent(
      name: 'student_update',
      parameters: {
        'student_name': studentName,
        'father_name': fatherName,
        'update_date': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logStudentDeletion(String studentName, String fatherName) async {
    await _analytics.logEvent(
      name: 'student_deletion',
      parameters: {
        'student_name': studentName,
        'father_name': fatherName,
        'deletion_date': DateTime.now().toIso8601String(),
      },
    );
  }

  // ? Student Enrollment End

  // Add more custom events as needed
}
