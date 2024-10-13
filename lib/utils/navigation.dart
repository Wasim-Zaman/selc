import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Navigations {
  static void push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: screen,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static void pushReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: screen,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void pushAndRemoveUntil(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: screen,
        duration: const Duration(milliseconds: 300),
      ),
      (Route<dynamic> route) => false,
    );
  }

  static void popWithResult<T>(BuildContext context, T result) {
    Navigator.of(context).pop(result);
  }
}
