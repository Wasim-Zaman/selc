import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/cubits/admissions/admissions_cubit.dart';
import 'package:gep/cubits/admissions/admissions_state.dart';
import 'package:gep/models/admission_announcement.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_text_button.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:material_ui/material_ui.dart';

class AdminAdmissionsScreen extends StatefulWidget {
  const AdminAdmissionsScreen({super.key});

  @override
  State<AdminAdmissionsScreen> createState() => _AdminAdmissionsScreenState();
}

class _AdminAdmissionsScreenState extends State<AdminAdmissionsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<AdmissionsCubit>().fetchPage(0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;
    final adminCubit = context.read<AdminCubit>();

    return AppScaffold(
      title: 'Manage Admissions',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddEditDialog(context, adminCubit),
        ),
      ],
      body: BlocConsumer<AdmissionsCubit, AdmissionsState>(
        listener: (context, state) {
          if (state.error != null && !state.isLoading && !state.isRefreshing) {
            TopSnackbar.error(context, state.error!);
          }
        },
        builder: (context, state) {
          final items = state.items;
          final isLoading = state.isLoading && items.isEmpty;

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
                            onChanged: (v) => context
                                .read<AdmissionsCubit>()
                                .setSearchQuery(v),
                            decoration: InputDecoration(
                              hintText: 'Search announcements…',
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
                              context.read<AdmissionsCubit>().clearSearch();
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
              else if (state.error != null && items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Failed to load announcements',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      state.searchQuery.isEmpty
                          ? 'No announcements available'
                          : 'No matches for "${state.searchQuery}"',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final announcement = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AnnouncementCard(
                          announcement: announcement,
                          onEdit: () => _showAddEditDialog(
                            context,
                            adminCubit,
                            announcement: announcement,
                          ),
                          onDelete: () => _deleteAnnouncement(
                            context,
                            adminCubit,
                            announcement.id,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (30 + index * 20).ms)
                          .slideY(begin: 0.05, end: 0);
                    }, childCount: items.length),
                  ),
                ),

              // Pagination
              if (items.isNotEmpty)
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
                          context.read<AdmissionsCubit>().previousPage(),
                      onNext: () =>
                          context.read<AdmissionsCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<AdmissionsCubit>().goToPage(page),
                      onRefresh: () =>
                          context.read<AdmissionsCubit>().refresh(),
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

  void _showAddEditDialog(BuildContext context, AdminCubit adminCubit,
      {AdmissionAnnouncement? announcement}) {
    showDialog(
      context: context,
      builder: (context) => AddEditAnnouncementDialog(
        adminCubit: adminCubit,
        announcement: announcement,
      ),
    );
  }

  void _deleteAnnouncement(
      BuildContext context, AdminCubit adminCubit, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content:
            const Text('Are you sure you want to delete this announcement?'),
        actions: [
          AppTextButton(
            onPressed: () => Navigator.pop(context),
            label: 'Cancel',
          ),
          AppTextButton(
            onPressed: () {
              adminCubit.deleteAdmissionAnnouncement(id);
              Navigator.pop(context);
            },
            label: 'Delete',
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final AdmissionAnnouncement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnnouncementCard({
    super.key,
    required this.announcement,
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
      child: ListTile(
        title: Text(
          announcement.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${_formatDate(announcement.startDate)} - ${_formatDate(announcement.endDate)}',
          style: theme.textTheme.bodySmall,
        ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AddEditAnnouncementDialog extends StatefulWidget {
  final AdminCubit adminCubit;
  final AdmissionAnnouncement? announcement;

  const AddEditAnnouncementDialog({
    super.key,
    required this.adminCubit,
    this.announcement,
  });

  @override
  State<AddEditAnnouncementDialog> createState() =>
      _AddEditAnnouncementDialogState();
}

class _AddEditAnnouncementDialogState extends State<AddEditAnnouncementDialog> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title);
    _detailsController =
        TextEditingController(text: widget.announcement?.details);
    _startDate = widget.announcement?.startDate ?? DateTime.now();
    _endDate = widget.announcement?.endDate ??
        DateTime.now().add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.announcement == null
          ? 'Add Announcement'
          : 'Edit Announcement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextButton(
                    onPressed: () => _selectDate(context, isStartDate: true),
                    label: 'Start: ${_formatDate(_startDate)}',
                  ),
                ),
                Expanded(
                  child: AppTextButton(
                    onPressed: () => _selectDate(context, isStartDate: false),
                    label: 'End: ${_formatDate(_endDate)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        AppTextButton(
          onPressed: () => Navigator.pop(context),
          label: 'Cancel',
        ),
        AppTextButton(
          onPressed: _saveAnnouncement,
          label: 'Save',
        ),
      ],
    );
  }

  void _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveAnnouncement() {
    final announcement = AdmissionAnnouncement(
      id: widget.announcement?.id ?? '',
      title: _titleController.text,
      details: _detailsController.text,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (widget.announcement == null) {
      widget.adminCubit.addAdmissionAnnouncement(announcement);
    } else {
      widget.adminCubit.updateAdmissionAnnouncement(announcement);
    }

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
}
