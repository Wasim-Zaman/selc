import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:selc/utils/navigation.dart';

class GridItem extends StatelessWidget {
  final String title;
  final String lottieUrl;
  final LinearGradient gradient;
  final Widget? screen;
  final Function(BuildContext)? onTap;

  const GridItem({
    super.key,
    required this.title,
    required this.lottieUrl,
    required this.gradient,
    this.screen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(context);
        } else if (screen != null) {
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
                  return _buildFallbackIcon(title);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(String title) {
    IconData iconData;
    switch (title.toLowerCase()) {
      case 'notes':
        iconData = Icons.note;
        break;
      case 'playlists':
        iconData = Icons.playlist_play;
        break;
      case 'courses & \noutlines':
        iconData = Icons.book;
        break;
      case 'updates':
        iconData = Icons.update;
        break;
      case 'admissions':
        iconData = Icons.school;
        break;
      case 'about me':
        iconData = Icons.person;
        break;
      default:
        iconData = Icons.error;
    }

    return Icon(iconData, size: 48);
  }
}
