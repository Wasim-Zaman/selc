import 'package:flutter/material.dart';

class Navigations {
  // Method to push a new screen (without removing the previous one)
  static void push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Method to replace the current screen (removes the previous screen)
  static void pushReplacement(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Method to pop the current screen (go back)
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Method to push and remove all previous routes (used for logging out or resetting the app)
  static void pushAndRemoveUntil(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  // Method to navigate back to the previous screen with a result
  static void popWithResult<T>(BuildContext context, T result) {
    Navigator.of(context).pop(result);
  }
}
