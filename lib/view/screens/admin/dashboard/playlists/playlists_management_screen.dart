import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/view/screens/admin/dashboard/playlists/add_playlist_screen.dart';

class PlaylistsManagementScreen extends StatelessWidget {
  const PlaylistsManagementScreen({super.key});

  void _navigateToAddPlaylist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPlaylistScreen()),
    );
  }

  void _navigateToEditPlaylist(BuildContext context, PlaylistModel playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddPlaylistScreen(playlist: playlist)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Playlists')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<PlaylistModel>>(
            stream: context.read<AdminCubit>().getPlaylistsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final playlists = snapshot.data!;

              if (playlists.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No playlists added yet.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _navigateToAddPlaylist(context),
                        child: const Text('Add New Playlist'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: playlists.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: ListTile(
                      title: Text(
                        playlist.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${playlist.videos.length} videos',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: theme.colorScheme.primary),
                            onPressed: () =>
                                _navigateToEditPlaylist(context, playlist),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: theme.colorScheme.error),
                            onPressed: () => context
                                .read<AdminCubit>()
                                .deletePlaylist(playlist.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _navigateToAddPlaylist(context),
      ),
    );
  }
}
