import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/router/app_navigation.dart';
import 'package:selc/router/app_routes.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/view/widgets/placeholder_widget.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  LinearGradient _generateGradient() {
    final random = Random();
    final baseColor =
        AppColors.randomColors[random.nextInt(AppColors.randomColors.length)];
    return LinearGradient(
      colors: [
        baseColor.withValues(alpha: 0.7),
        baseColor.withValues(alpha: 0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Playlists',
            style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: StreamBuilder<List<PlaylistModel>>(
        stream: context.read<AdminCubit>().getPlaylistsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PlaceholderWidgets.gridPlaceholder();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No playlists available'));
          }

          final playlists = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: AppConstants.defaultPadding,
              mainAxisSpacing: AppConstants.defaultPadding,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              return PlaylistGridItem(
                playlist: playlists[index],
                gradient: _generateGradient(),
                onTap: () {
                  AppNavigation.push(context, AppRoutes.kPlaylistDetailRoute,
                      extra: playlists[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PlaylistGridItem extends StatelessWidget {
  final PlaylistModel playlist;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const PlaylistGridItem({
    super.key,
    required this.playlist,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        elevation: AppConstants.defaultElevation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            gradient: gradient,
          ),
          child: Center(
            child: Text(
              playlist.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
