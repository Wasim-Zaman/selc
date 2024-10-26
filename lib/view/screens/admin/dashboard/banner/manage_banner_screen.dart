import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/banner.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';

class ManageBannerScreen extends StatelessWidget {
  const ManageBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminCubit = context.read<AdminCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Banners', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(context, adminCubit),
          ),
        ],
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminSuccess) {
            TopSnackbar.success(context, state.message);
          } else if (state is AdminFailure) {
            TopSnackbar.error(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<BannerModel>>(
            stream: adminCubit.getBannersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No banners available'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return BannerCard(
                    banner: snapshot.data![index],
                    onEdit: () => _showAddEditDialog(
                      context,
                      adminCubit,
                      banner: snapshot.data![index],
                    ),
                    onDelete: () => _deleteBanner(
                      context,
                      adminCubit,
                      snapshot.data![index].id,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, AdminCubit adminCubit,
      {BannerModel? banner}) {
    showDialog(
      context: context,
      builder: (context) =>
          AddEditBannerDialog(adminCubit: adminCubit, banner: banner),
    );
  }

  void _deleteBanner(
      BuildContext context, AdminCubit adminCubit, String bannerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this banner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              adminCubit.deleteBanner(bannerId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BannerCard({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Image.network(
          banner.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(banner.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditBannerDialog extends StatefulWidget {
  final AdminCubit adminCubit;
  final BannerModel? banner;

  const AddEditBannerDialog({super.key, required this.adminCubit, this.banner});

  @override
  State<AddEditBannerDialog> createState() => _AddEditBannerDialogState();
}

class _AddEditBannerDialogState extends State<AddEditBannerDialog> {
  late TextEditingController _titleController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Load the image file
      final File imageFile = File(pickedFile.path);
      final img = await decodeImageFromList(await imageFile.readAsBytes());

      // Create an image with the desired resolution
      final ui.Image resizedImage = await _resizeImage(img, 1200, 480);

      // Convert to bytes and create a new file
      final byteData =
          await resizedImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/resized_banner.png');
      await tempFile.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      setState(() {
        _imageFile = tempFile;
      });
    }
  }

  Future<ui.Image> _resizeImage(
      ui.Image image, int targetWidth, int targetHeight) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = pictureRecorder.endRecording();
    return picture.toImage(targetWidth, targetHeight);
  }

  void _saveBanner() {
    if (_titleController.text.isEmpty ||
        (_imageFile == null && widget.banner == null)) {
      TopSnackbar.error(context, 'Please fill all fields');
      return;
    }

    if (widget.banner == null) {
      widget.adminCubit.addBanner(_titleController.text, _imageFile!);
    } else {
      widget.adminCubit.updateBanner(
        widget.banner!.copyWith(title: _titleController.text),
        _imageFile,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.banner == null ? 'Add Banner' : 'Edit Banner'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Text(
              'Recommended image resolution: 1200x480 pixels\nImages will be automatically resized',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            if (_imageFile != null)
              Image.file(_imageFile!,
                  height: 100, width: 100, fit: BoxFit.cover)
            else if (widget.banner != null)
              Image.network(widget.banner!.imageUrl,
                  height: 100, width: 100, fit: BoxFit.cover),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveBanner,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
