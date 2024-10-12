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

  // Add more custom events as needed
}
