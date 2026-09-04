import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/cubits/banners/banners_cubit.dart';
import 'package:gep/cubits/banners/banners_state.dart';
import 'package:gep/models/banner.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_dialog.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
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

    return BlocConsumer<BannersCubit, BannersState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading && !state.isRefreshing) {
          TopSnackbar.error(context, state.error!);
        }
      },
      builder: (context, state) {
        final banners = state.items;
        final isLoading = state.isLoading && banners.isEmpty;

        return AppScaffold(
          title: 'Banners',
          floatingActionButton: isLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showAddEditSheet(context, adminCubit),
                  tooltip: 'Add Banner',
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Banner'),
                ),
          bottomNavigationBar: banners.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: SafeArea(
                    top: false,
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
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async => context.read<BannersCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search banners',
                    hintText: 'Search banners…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: textColorSecondary,
                            onPressed: () {
                              _searchController.clear();
                              context.read<BannersCubit>().clearSearch();
                            },
                          )
                        : null,
                    onChanged: (v) =>
                        context.read<BannersCubit>().setSearchQuery(v),
                  ),
                ),

                // Header Label & Badge
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.view_carousel_rounded,
                            size: 16,
                            color: textColorSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'AVAILABLE BANNERS'
                                : 'SEARCH RESULTS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (!isLoading && banners.isNotEmpty)
                        Badge(
                          label: Text('${banners.length}'),
                          backgroundColor: isDark
                              ? AppColors.darkNeutral
                              : AppColors.lightNeutral,
                          textColor: isDark
                              ? AppColors.darkBodyText
                              : AppColors.lightBodyText,
                        ),
                    ],
                  ),
                ),

                // Body Content States
                if (isLoading)
                  PlaceholderWidgets.listPlaceholder()
                else if (state.error != null && banners.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load banners',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.error!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (banners.isEmpty)
                  _EmptyState(
                    onAdd: () => _showAddEditSheet(context, adminCubit),
                    searchQuery: state.searchQuery,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: banners.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return _BannerItemCard(
                        banner: banner,
                        onEdit: () => _showAddEditSheet(
                          context,
                          adminCubit,
                          banner: banner,
                        ),
                        onDelete: () => _confirmDelete(adminCubit, banner),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditSheet(
    BuildContext context,
    AdminCubit adminCubit, {
    BannerModel? banner,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => BannerImageCubit(),
        child: AddEditBannerSheet(adminCubit: adminCubit, banner: banner),
      ),
    );
  }

  Future<void> _confirmDelete(
    AdminCubit adminCubit,
    BannerModel banner,
  ) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Banner',
      message: 'Are you sure you want to delete "${banner.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      try {
        await adminCubit.deleteBanner(banner.id);
      } catch (e) {
        if (mounted) {
          TopSnackbar.error(context, 'Failed to delete banner: $e');
        }
      }
    }
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
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
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
                top: Radius.circular(15),
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

class AddEditBannerSheet extends StatefulWidget {
  final AdminCubit adminCubit;
  final BannerModel? banner;

  const AddEditBannerSheet({
    super.key,
    required this.adminCubit,
    this.banner,
  });

  @override
  State<AddEditBannerSheet> createState() => _AddEditBannerSheetState();
}

class _AddEditBannerSheetState extends State<AddEditBannerSheet> {
  late final TextEditingController _titleController;
  bool _isSaving = false;

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

  Future<void> _save(BuildContext context, File? imageFile) async {
    final title = _titleController.text.trim();
    if (title.isEmpty || (imageFile == null && widget.banner == null)) {
      TopSnackbar.error(context, 'Please provide title and image');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.banner == null) {
        await widget.adminCubit.addBanner(title, imageFile!);
      } else {
        await widget.adminCubit.updateBanner(
          widget.banner!.copyWith(title: title),
          imageFile,
        );
      }

      if (!context.mounted) return;

      // Refresh the banners list so the new/edited banner appears
      context.read<BannersCubit>().refresh();

      Navigator.of(context).pop();
      TopSnackbar.success(
        context,
        widget.banner == null
            ? 'Banner added successfully'
            : 'Banner updated successfully',
      );
    } catch (e) {
      if (!context.mounted) return;
      TopSnackbar.error(context, 'Failed to save banner: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageCubit = context.read<BannerImageCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkScaffoldBackground
        : AppColors.lightScaffoldBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: AppScaffold(
          title: widget.banner == null ? 'Add Banner' : 'Edit Banner',
          body: ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              TextFieldWidget(
                controller: _titleController,
                labelText: 'Banner Title',
                prefixIcon: Icons.title_rounded,
              ),
              const SizedBox(height: 16),
              BlocBuilder<BannerImageCubit, BannerImageState>(
                builder: (context, state) {
                  final isProcessing = state is BannerImageProcessing;
                  final File? pickedFile = state is BannerImageSuccess
                      ? state.imageFile
                      : null;

                  return Material(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _isSaving || isProcessing
                          ? null
                          : () => imageCubit.pickAndProcessBanner(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: isProcessing
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : pickedFile != null
                                  ? Image.file(pickedFile, fit: BoxFit.cover)
                                  : widget.banner != null
                                      ? CachedNetworkImage(
                                          imageUrl: widget.banner!.imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (_, _) => Container(
                                            color: isDark
                                                ? Colors.white10
                                                : Colors.black12,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          ),
                                          errorWidget: (_, _, _) => Container(
                                            color: isDark
                                                ? Colors.white10
                                                : Colors.black12,
                                            child: const Icon(
                                              Icons.broken_image_rounded,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
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
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding * 2),
              BlocBuilder<BannerImageCubit, BannerImageState>(
                builder: (context, state) {
                  final File? pickedFile = state is BannerImageSuccess
                      ? state.imageFile
                      : null;
                  final bool canSave = !_isSaving &&
                      (pickedFile != null || widget.banner != null);
                  return AppButton(
                    label: _isSaving ? 'Saving…' : 'Save',
                    onPressed: canSave
                        ? () => _save(context, pickedFile)
                        : null,
                  );
                },
              ),
              SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom + 24),
            ],
          ),
        ),
      ),
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
    final isDark = theme.brightness == Brightness.dark;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_carousel_outlined,
              size: 36,
              color: textColorSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty ? 'No Banners Found' : 'No Matches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              searchQuery.isEmpty
                  ? 'Tap the + button below to add your first banner'
                  : 'No banners match "$searchQuery"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColorSecondary,
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
