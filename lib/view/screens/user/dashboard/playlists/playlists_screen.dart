import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/utils/constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  late YoutubePlayerController _controller;
  final List<LinearGradient> playlistGradients = [];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
          'https://www.youtube.com/watch?v=vk5nQMexZjY')!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  LinearGradient _generateGradient() {
    final random = Random();
    final baseColor =
        AppColors.randomColors[random.nextInt(AppColors.randomColors.length)];
    return LinearGradient(
      colors: [
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
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
          title: Text('My Playlists',
              style: Theme.of(context).textTheme.headlineSmall),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<PlaylistModel>>(
                stream: context.read<AdminCubit>().getPlaylistsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No playlists available'));
                  }

                  final playlists = snapshot.data!;

                  // Generate gradients for each playlist
                  if (playlistGradients.length != playlists.length) {
                    playlistGradients.clear();
                    for (var _ in playlists) {
                      playlistGradients.add(_generateGradient());
                    }
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return PlaylistCard(
                        playlist: playlists[index],
                        gradient: playlistGradients[index],
                        onVideoSelected: (videoLink) {
                          final videoId =
                              YoutubePlayer.convertUrlToId(videoLink);
                          if (videoId != null) {
                            _controller.load(videoId);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              height: 240,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                child: player,
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

class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final LinearGradient gradient;
  final Function(String) onVideoSelected;

  const PlaylistCard({
    Key? key,
    required this.playlist,
    required this.gradient,
    required this.onVideoSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      elevation: AppConstants.defaultElevation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          gradient: gradient,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              playlist.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            children: playlist.videos.map<Widget>((video) {
              return ListTile(
                title: Text(video.title),
                leading: const Icon(
                  Icons.play_circle_outline,
                  size: AppConstants.defaultIconSize,
                ),
                onTap: () => onVideoSelected(video.link),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
