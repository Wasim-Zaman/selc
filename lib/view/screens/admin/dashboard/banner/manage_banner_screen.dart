import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/cubits/banners/banners_cubit.dart';
import 'package:gep/cubits/banners/banners_state.dart';
import 'package:gep/models/banner.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_text_button.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../cubits/banner/banner_image_cubit.dart';

class ManageBannerScreen extends StatefulWidget {
  const ManageBannerScreen({super.key});

  @override
  State<ManageBannerScreen> createState() => _ManageBannerScreenState();
}

class _ManageBannerScreenState extends State<ManageBannerScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<BannersCubit>().fetchPage(0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminCubit = context.read<AdminCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return AppScaffold(
      title: 'Banners',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Add Banner',
          onPressed: () => _showAddEditDialog(context, adminCubit),
        ),
      ],
      body: BlocConsumer<BannersCubit, BannersState>(
        listener: (context, state) {
          if (state.error != null && !state.isLoading && !state.isRefreshing) {
            TopSnackbar.error(context, state.error!);
          }
        },
        builder: (context, state) {
          final banners = state.items;
          final isLoading = state.isLoading && banners.isEmpty;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    12,
                    AppConstants.defaultPadding,
                    12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            size: 20, color: textColorSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) =>
                                context.read<BannersCubit>().setSearchQuery(v),
                            decoration: InputDecoration(
                              hintText: 'Search banners…',
                              hintStyle: theme.textTheme.bodyMedium
                                  ?.copyWith(color: textColorSecondary),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context.read<BannersCubit>().clearSearch();
                            },
                            child: Icon(Icons.close_rounded,
                                size: 18, color: textColorSecondary),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null && banners.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Failed to load banners',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else if (banners.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    onAdd: () => _showAddEditDialog(context, adminCubit),
                    searchQuery: state.searchQuery,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final banner = banners[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _BannerItemCard(
                          banner: banner,
                          onEdit: () => _showAddEditDialog(
                            context,
                            adminCubit,
                            banner: banner,
                          ),
                          onDelete: () =>
                              _confirmDelete(context, adminCubit, banner.id),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (30 + index * 20).ms)
                          .slideY(begin: 0.05, end: 0);
                    }, childCount: banners.length),
                  ),
                ),

              // Pagination
              if (banners.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      8,
                      AppConstants.defaultPadding,
                      24,
                    ),
                    child: PaginatedWidget(
                      isLoading: state.isLoading || state.isRefreshing,
                      hasPrevious: state.currentPage > 0,
                      hasNext: state.hasMore,
                      onPrevious: () =>
                          context.read<BannersCubit>().previousPage(),
                      onNext: () => context.read<BannersCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<BannersCubit>().goToPage(page),
                      onRefresh: () => context.read<BannersCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 10,
                    ),
                  ),
                ),
            ],
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
    context.pop();
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
                      : () => imageCubit.pickAndProcessBanner(context),
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
                                  ? Image.network(banner!.imageUrl,
                                      fit: BoxFit.cover)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
        AppTextButton(
            label: 'Cancel', onPressed: () => Navigator.pop(context)),
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
  final String searchQuery;

  const _EmptyState({required this.onAdd, required this.searchQuery});

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
              searchQuery.isEmpty ? 'No Banners Found' : 'No Matches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              searchQuery.isEmpty
                  ? 'Create display banners for promotions and announcements.'
                  : 'No banners match "$searchQuery"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (searchQuery.isEmpty)
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
