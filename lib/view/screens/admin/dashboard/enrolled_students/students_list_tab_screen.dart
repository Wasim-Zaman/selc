// ignore_for_file: use_build_context_synchronously

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/enrolled_students_admin/enrolled_students_cubit.dart';
import 'package:gep/cubits/enrolled_students_admin/enrolled_students_state.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_delete_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_text_button.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class StudentsListTab extends StatefulWidget {
  const StudentsListTab({super.key});

  @override
  State<StudentsListTab> createState() => _StudentsListTabState();
}

class _StudentsListTabState extends State<StudentsListTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<EnrolledStudentsAdminCubit>().fetchPage(0);
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

    return AppScaffold(
      body: BlocConsumer<EnrolledStudentsAdminCubit, EnrolledStudentsState>(
        listener: (context, state) {
          if (state.error != null && !state.isLoading && !state.isRefreshing) {
            TopSnackbar.error(context, state.error!);
          }
        },
        builder: (context, state) {
          final students = state.items;
          final isLoading = state.isLoading && students.isEmpty;

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
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search students',
                    hintText: 'Search students…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context
                                  .read<EnrolledStudentsAdminCubit>()
                                  .clearSearch();
                            },
                            child: Icon(Icons.close_rounded,
                                size: 18, color: textColorSecondary),
                          )
                        : null,
                    onChanged: (v) => context
                        .read<EnrolledStudentsAdminCubit>()
                        .setSearchQuery(v),
                  ),
                ),
              ),

              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null && students.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text('Failed to load students',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else if (students.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.searchQuery.isEmpty
                              ? 'No students available'
                              : 'No matches for "${state.searchQuery}"',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (state.searchQuery.isEmpty)
                          AppButton(
                            onPressed: () => _addStudent(context),
                            label: 'Add New Student',
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
                      final student = students[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(student.name[0]),
                            ),
                            title: Text(
                              student.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              student.level,
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: theme.colorScheme.primary),
                                  onPressed: () => _editStudent(context, student),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: theme.colorScheme.error),
                                  onPressed: () =>
                                      _confirmDelete(context, student),
                                ),
                              ],
                            ),
                            onTap: () => _showStudentDetails(context, student),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (30 + index * 20).ms)
                          .slideY(begin: 0.05, end: 0);
                    }, childCount: students.length),
                  ),
                ),

              // Pagination
              if (students.isNotEmpty)
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
                      onPrevious: () => context
                          .read<EnrolledStudentsAdminCubit>()
                          .previousPage(),
                      onNext: () =>
                          context.read<EnrolledStudentsAdminCubit>().nextPage(),
                      onPageSelected: (page) => context
                          .read<EnrolledStudentsAdminCubit>()
                          .goToPage(page),
                      onRefresh: () =>
                          context.read<EnrolledStudentsAdminCubit>().refresh(),
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
        onPressed: () => _addStudent(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editStudent(BuildContext context, EnrolledStudent student) async {
    final result = await AppNavigation.pushForResult<bool>(
      context,
      AppRoutes.kEditStudentRoute,
      extra: {'student': student},
    );

    if (result == true) {
      TopSnackbar.success(context, 'Student updated successfully');
    }
  }

  void _showStudentDetails(BuildContext context, EnrolledStudent student) {
    AppNavigation.push(context, AppRoutes.kStudentDetailsRoute, extra: student);
  }

  void _addStudent(BuildContext context) async {
    final result = await AppNavigation.pushForResult<bool>(
      context,
      AppRoutes.kAddStudentRoute,
    );

    if (result == true) {
      TopSnackbar.success(context, 'Student added successfully');
    }
  }

  void _confirmDelete(BuildContext context, EnrolledStudent student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this student?'),
          actions: [
            AppTextButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            AppDeleteButton(
              label: 'Delete',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      context.read<EnrolledStudentsAdminCubit>().deleteStudent(student.id);
    }
  }
}
