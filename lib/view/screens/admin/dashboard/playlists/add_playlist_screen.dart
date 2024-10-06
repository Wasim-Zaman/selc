import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/widgets/text_field_widget.dart';

class AddPlaylistScreen extends StatefulWidget {
  final PlaylistModel? playlist;

  const AddPlaylistScreen({Key? key, this.playlist}) : super(key: key);

  @override
  _AddPlaylistScreenState createState() => _AddPlaylistScreenState();
}

class _AddPlaylistScreenState extends State<AddPlaylistScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _videoTitleController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();
  late List<VideoModel> _videos;

  @override
  void initState() {
    super.initState();
    if (widget.playlist != null) {
      _nameController.text = widget.playlist!.name;
      _videos = List.from(widget.playlist!.videos);
    } else {
      _videos = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _videoTitleController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  void _addVideo() {
    if (_videoTitleController.text.isNotEmpty &&
        _videoLinkController.text.isNotEmpty) {
      setState(() {
        _videos.add(VideoModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _videoTitleController.text,
          link: _videoLinkController.text,
        ));
        _videoTitleController.clear();
        _videoLinkController.clear();
      });
    }
  }

  void _removeVideo(int index) {
    setState(() {
      _videos.removeAt(index);
    });
  }

  void _submitPlaylist(BuildContext context) {
    if (_nameController.text.isNotEmpty && _videos.isNotEmpty) {
      final playlist = PlaylistModel(
        id: widget.playlist?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        videos: _videos,
      );
      if (widget.playlist != null) {
        context.read<AdminCubit>().updatePlaylist(playlist.id, playlist);
      } else {
        context.read<AdminCubit>().addPlaylist(playlist);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.playlist != null ? 'Edit Playlist' : 'Add New Playlist'),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminSuccess) {
            TopSnackbar.success(context, state.message);
            Navigator.pop(context);
          } else if (state is AdminFailure) {
            TopSnackbar.error(context, 'Error: ${state.error}');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFieldWidget(
                    controller: _nameController,
                    labelText: 'Playlist Name',
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _videoTitleController,
                    labelText: 'Video Title',
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _videoLinkController,
                    labelText: 'Video Link',
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ElevatedButton(
                    onPressed: _addVideo,
                    child: const Text('Add Video to Playlist'),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      final video = _videos[index];
                      return ListTile(
                        title: Text(video.title),
                        subtitle: Text(video.link),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeVideo(index),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  if (state is AdminLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: () => _submitPlaylist(context),
                      child: Text(widget.playlist != null
                          ? 'Update Playlist'
                          : 'Create Playlist'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
