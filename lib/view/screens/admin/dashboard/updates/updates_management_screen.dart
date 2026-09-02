import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/updates_admin/updates_admin_cubit.dart';
import 'package:gep/cubits/updates_admin/updates_admin_state.dart';
import 'package:gep/models/updates.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_text_button.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class UpdatesManagementScreen extends StatefulWidget {
  const UpdatesManagementScreen({super.key});

  @override
  State<UpdatesManagementScreen> createState() =>
      _UpdatesManagementScreenState();
}

class _UpdatesManagementScreenState extends State<UpdatesManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _searchController;
  late DateTime _selectedDate;
  UpdateType _selectedType = UpdateType.newCourse;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _searchController = TextEditingController();
    context.read<UpdatesAdminCubit>().fetchPage(0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedType = UpdateType.newCourse;
    });
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

    return AppScaffold(
      title: 'Updates Management',
      body: BlocConsumer<UpdatesAdminCubit, UpdatesAdminState>(
        listener: (context, state) {
          if (state.error != null && !state.isLoading && !state.isRefreshing) {
            TopSnackbar.error(context, state.error!);
          }
        },
        builder: (context, state) {
          final updates = state.items;
          final isLoading = state.isLoading && updates.isEmpty;

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
                                .read<UpdatesAdminCubit>()
                                .setSearchQuery(v),
                            decoration: InputDecoration(
                              hintText: 'Search updates…',
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
                              context.read<UpdatesAdminCubit>().clearSearch();
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
              else if (state.error != null && updates.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Failed to load updates',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else if (updates.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.searchQuery.isEmpty
                              ? 'No updates available'
                              : 'No matches for "${state.searchQuery}"',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (state.searchQuery.isEmpty)
                          AppButton(
                            label: 'Add New Update',
                            expanded: false,
                            onPressed: () => _showUpdateDialog(context, null),
                          ),
                      ],
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
                      final update = updates[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: ListTile(
                            title: Text(
                              update.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${update.formattedDate} - ${update.type.toString().split('.').last}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: theme.colorScheme.primary),
                                  onPressed: () =>
                                      _showUpdateDialog(context, update),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: theme.colorScheme.error),
                                  onPressed: () =>
                                      _confirmDelete(context, update.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (30 + index * 20).ms)
                          .slideY(begin: 0.05, end: 0);
                    }, childCount: updates.length),
                  ),
                ),

              // Pagination
              if (updates.isNotEmpty)
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
                          context.read<UpdatesAdminCubit>().previousPage(),
                      onNext: () =>
                          context.read<UpdatesAdminCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<UpdatesAdminCubit>().goToPage(page),
                      onRefresh: () =>
                          context.read<UpdatesAdminCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 10,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showUpdateDialog(context, null),
      ),
    );
  }

  Future<void> _showUpdateDialog(BuildContext context, Updates? update) async {
    if (update != null) {
      _titleController.text = update.title;
      _descriptionController.text = update.description;
      _selectedDate = update.date;
      _selectedType = update.type;
    } else {
      _resetForm();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(update == null ? 'Add New Update' : 'Edit Update'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(
                    controller: _titleController,
                    labelText: 'Title',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  TextFieldWidget(
                    controller: _descriptionController,
                    labelText: 'Description',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a description' : null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(_selectedDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  DropdownButtonFormField<UpdateType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: UpdateType.values.map((UpdateType type) {
                      return DropdownMenuItem<UpdateType>(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (UpdateType? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            AppTextButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              label: update == null ? 'Add' : 'Update',
              expanded: false,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newUpdate = Updates(
                    id: update?.id ?? '',
                    title: _titleController.text,
                    description: _descriptionController.text,
                    date: _selectedDate,
                    type: _selectedType,
                  );
                  if (update == null) {
                    context.read<UpdatesAdminCubit>().addUpdate(newUpdate);
                  } else {
                    context
                        .read<UpdatesAdminCubit>()
                        .updateUpdate(update.id, newUpdate);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String updateId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this update?'),
          actions: [
            AppTextButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            AppButton(
              label: 'Delete',
              expanded: false,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      context.read<UpdatesAdminCubit>().deleteUpdate(updateId);
    }
  }
}
