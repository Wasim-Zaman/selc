import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:selc/router/app_navigation.dart';
import 'package:selc/services/analytics/analytics_service.dart';

class GridItem extends StatelessWidget {
  final String title;
  final Gradient gradient;
  final String? routeName;
  final String lottieUrl;
  final IconData fallbackIcon;
  final Function? onTap;

  const GridItem({
    super.key,
    required this.title,
    required this.gradient,
    this.routeName,
    required this.lottieUrl,
    required this.fallbackIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (routeName != null) {
          final AnalyticsService analyticsService = AnalyticsService();
          await analyticsService.logButtonClick(title);
          // ignore: use_build_context_synchronously
          AppNavigation.push(context, routeName!);
        } else if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Lottie.asset(
                lottieUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(fallbackIcon, size: 50);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
