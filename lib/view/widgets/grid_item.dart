import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:selc/utils/navigation.dart';

class GridItem extends StatelessWidget {
  final String title;
  final Gradient gradient;
  final Widget? screen;
  final String lottieUrl;
  final IconData fallbackIcon;

  const GridItem({
    super.key,
    required this.title,
    required this.gradient,
    this.screen,
    required this.lottieUrl,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Navigations.push(context, screen!);
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
              child: Lottie.network(
                lottieUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    fallbackIcon,
                    size: 50,
                    color: Colors.white,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
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
