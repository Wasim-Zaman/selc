import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:upgrader/upgrader.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;

  const AppWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _requestReview();
  }

  Future<void> _requestReview() async {
    if (await inAppReview.isAvailable()) {
      // You can add your own logic here to determine when to request a review
      // For example, you might want to do this after a certain number of app opens
      inAppReview.requestReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
        debugDisplayAlways: true,
        minAppVersion: '1.0.0',
      ),
      child: widget.child,
    );
  }
}
