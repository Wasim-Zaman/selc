import 'package:material_ui/material_ui.dart';
import 'package:in_app_review/in_app_review.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
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
      // inAppReview.requestReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
