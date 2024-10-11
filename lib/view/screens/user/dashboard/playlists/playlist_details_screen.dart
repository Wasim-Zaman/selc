import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/utils/constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(widget.playlist.videos.first.link)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.secondary,
        ),
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          title: Text(widget.playlist.name,
              style: Theme.of(context).textTheme.headlineSmall),
          elevation: 0,
        ),
        body: Column(
          children: [
            player,
            const SizedBox(height: 10),
            Text(
                "${widget.playlist.name} - ${widget.playlist.videos.length} videos"),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.playlist.videos.length,
                itemBuilder: (context, index) {
                  final video = widget.playlist.videos[index];
                  return ListTile(
                    title: Text(video.title),
                    leading: const Icon(
                      Icons.play_circle_outline,
                      size: AppConstants.defaultIconSize,
                    ),
                    onTap: () {
                      final videoId = YoutubePlayer.convertUrlToId(video.link);
                      if (videoId != null) {
                        _controller.load(videoId);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
