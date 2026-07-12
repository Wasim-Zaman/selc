import 'package:flutter/material.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  Future<void> _launchVideo(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the video')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name,
            style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text(
              "${playlist.name} - ${playlist.videos.length} videos",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: playlist.videos.length,
              itemBuilder: (context, index) {
                final video = playlist.videos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                  child: ListTile(
                    title: Text(video.title),
                    leading: const Icon(
                      Icons.play_circle_outline,
                      size: AppConstants.defaultIconSize,
                      color: AppColors.primary,
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchVideo(video.link, context),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
