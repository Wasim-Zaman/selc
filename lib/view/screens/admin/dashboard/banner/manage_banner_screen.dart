import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/models/banner.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_text_button.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../cubits/banner/banner_image_cubit.dart';

class ManageBannerScreen extends StatelessWidget {
  const ManageBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminCubit = context.read<AdminCubit>();

    return AppScaffold(
      title: 'Banners',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Add Banner',
          onPressed: () => _showAddEditDialog(context, adminCubit),
        ),
      ],
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
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final banners = snapshot.data ?? [];
              if (banners.isEmpty) {
                return _EmptyState(
                  onAdd: () => _showAddEditDialog(context, adminCubit),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: banners.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return _BannerItemCard(
                    banner: banner,
                    onEdit: () =>
                        _showAddEditDialog(context, adminCubit, banner: banner),
                    onDelete: () =>
                        _confirmDelete(context, adminCubit, banner.id),
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
      builder: (_) => BlocProvider(
        create: (_) => BannerImageCubit(),
        child: AddEditBannerDialog(adminCubit: adminCubit, banner: banner),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AdminCubit adminCubit,
    String bannerId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this banner?'),
        actions: [
          AppTextButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
          AppTextButton(
            label: 'Delete',
            onPressed: () {
              adminCubit.deleteBanner(bannerId);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _BannerItemCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerItemCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNeutral : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: isDark ? Colors.white10 : Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: isDark ? Colors.white10 : Colors.black12,
                      child: const Icon(
                        Icons.broken_image_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: onEdit,
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: 18,
                            ),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              banner.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditBannerDialog extends StatelessWidget {
  final AdminCubit adminCubit;
  final BannerModel? banner;
  final TextEditingController _titleController;

  AddEditBannerDialog({super.key, required this.adminCubit, this.banner})
    : _titleController = TextEditingController(text: banner?.title ?? '');

  void _save(BuildContext context, File? imageFile) {
    final title = _titleController.text.trim();
    if (title.isEmpty || (imageFile == null && banner == null)) {
      TopSnackbar.error(context, 'Please provide title and image');
      return;
    }

    if (banner == null) {
      adminCubit.addBanner(title, imageFile!);
    } else {
      adminCubit.updateBanner(banner!.copyWith(title: title), imageFile);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageCubit = context.read<BannerImageCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(banner == null ? 'Add Banner' : 'Edit Banner'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Banner Title',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<BannerImageCubit, BannerImageState>(
              builder: (context, state) {
                final isProcessing = state is BannerImageProcessing;
                final File? pickedFile = state is BannerImageSuccess
                    ? state.imageFile
                    : null;

                return InkWell(
                  onTap: isProcessing
                      ? null
                      : () => imageCubit.pickAndProcessBanner(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkNeutral
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isProcessing
                          ? const Center(child: CircularProgressIndicator())
                          : pickedFile != null
                          ? Image.file(pickedFile, fit: BoxFit.cover)
                          : banner != null
                          ? Image.network(banner!.imageUrl, fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 32,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Select Image (1200x480)',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        AppTextButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        BlocBuilder<BannerImageCubit, BannerImageState>(
          builder: (context, state) {
            final File? pickedFile = state is BannerImageSuccess
                ? state.imageFile
                : null;
            return AppButton(
              label: 'Save',
              expanded: false,
              height: 38,
              onPressed: () => _save(context, pickedFile),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_carousel_outlined,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Banners Found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create display banners for promotions and announcements.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Add Banner',
              icon: const Icon(Icons.add_rounded),
              expanded: false,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
