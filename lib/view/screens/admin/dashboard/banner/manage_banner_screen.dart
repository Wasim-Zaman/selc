import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/models/banner.dart';
import 'package:gep/utils/snackbars.dart';

import '../../../../../cubits/banner/banner_image_cubit.dart';

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

  void _showAddEditDialog(
    BuildContext context,
    AdminCubit adminCubit, {
    BannerModel? banner,
  }) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (_) => BannerImageCubit(),
        child: AddEditBannerDialog(adminCubit: adminCubit, banner: banner),
      ),
    );
  }

  void _deleteBanner(
    BuildContext context,
    AdminCubit adminCubit,
    String bannerId,
  ) {
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
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: banner.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
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

class AddEditBannerDialog extends StatelessWidget {
  final AdminCubit adminCubit;
  final BannerModel? banner;
  final TextEditingController _titleController;

  AddEditBannerDialog({
    super.key,
    required this.adminCubit,
    this.banner,
  }) : _titleController = TextEditingController(text: banner?.title ?? '');

  void _saveBanner(BuildContext context, File? selectedImageFile) {
    if (_titleController.text.isEmpty ||
        (selectedImageFile == null && banner == null)) {
      TopSnackbar.error(context, 'Please fill all fields');
      return;
    }

    if (banner == null) {
      adminCubit.addBanner(_titleController.text, selectedImageFile!);
    } else {
      adminCubit.updateBanner(
        banner!.copyWith(title: _titleController.text),
        selectedImageFile,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageCubit = context.read<BannerImageCubit>();

    return AlertDialog(
      title: Text(banner == null ? 'Add Banner' : 'Edit Banner'),
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
            const SizedBox(height: 12),
            BlocBuilder<BannerImageCubit, BannerImageState>(
              builder: (context, state) {
                final isProcessing = state is BannerImageProcessing;
                return ElevatedButton.icon(
                  onPressed: isProcessing
                      ? null
                      : () => imageCubit.pickAndProcessBanner(),
                  icon: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.image_search),
                  label: Text(
                    isProcessing ? 'Processing...' : 'Pick Image',
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            BlocBuilder<BannerImageCubit, BannerImageState>(
              builder: (context, state) {
                if (state is BannerImageSuccess) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      state.imageFile,
                      height: 100,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  );
                }

                if (banner != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      banner!.imageUrl,
                      height: 100,
                      width: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        width: 250,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocBuilder<BannerImageCubit, BannerImageState>(
          builder: (context, state) {
            final File? selectedFile =
                state is BannerImageSuccess ? state.imageFile : null;
            final isProcessing = state is BannerImageProcessing;

            return ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () => _saveBanner(context, selectedFile),
              child: const Text('Save'),
            );
          },
        ),
      ],
    );
  }
}
