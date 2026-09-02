import 'dart:math';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/user_students/user_students_cubit.dart';
import 'package:gep/cubits/user_students/user_students_state.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_text_button.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class EnrolledStudentsScreen extends StatefulWidget {
  const EnrolledStudentsScreen({super.key});

  @override
  State<EnrolledStudentsScreen> createState() => _EnrolledStudentsScreenState();
}

class _EnrolledStudentsScreenState extends State<EnrolledStudentsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<UserStudentsCubit>().fetchPage(0);
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
      title: 'Enrolled Students',
      body: BlocBuilder<UserStudentsCubit, UserStudentsState>(
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
                                .read<UserStudentsCubit>()
                                .setSearchQuery(v),
                            decoration: InputDecoration(
                              hintText: 'Search students…',
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
                              context.read<UserStudentsCubit>().clearSearch();
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
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: PlaceholderWidgets.listPlaceholder(itemCount: 10),
                  ),
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
                    child: Text(
                      state.searchQuery.isEmpty
                          ? 'No students available'
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
                      final student = students[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StudentCard(
                          student: student,
                          index: index,
                          onTap: () => _showStudentDetails(context, student),
                        ),
                      );
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
                      onPrevious: () =>
                          context.read<UserStudentsCubit>().previousPage(),
                      onNext: () =>
                          context.read<UserStudentsCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<UserStudentsCubit>().goToPage(page),
                      onRefresh: () =>
                          context.read<UserStudentsCubit>().refresh(),
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

  void _showStudentDetails(BuildContext context, EnrolledStudent student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _StudentDetailsCard(student: student),
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  final EnrolledStudent student;
  final int index;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.index,
    required this.onTap,
  });

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = AppColors.randomColors[index % AppColors.randomColors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Text(
                  _getInitials(student.name),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Level: ${student.level}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkBodyTextSecondary
                            : AppColors.lightBodyTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enrolled: ${DateFormat('MMM d, yyyy').format(student.enrollmentDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkBodyTextSecondary
                            : AppColors.lightBodyTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.darkBodyTextSecondary
                    : AppColors.lightBodyTextSecondary,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (30 + index * 20).ms)
        .slideY(begin: 0.05, end: 0);
  }
}

class _StudentDetailsCard extends StatelessWidget {
  final EnrolledStudent student;

  const _StudentDetailsCard({required this.student});

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 80,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                student.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(icon: Icons.school_rounded, label: 'Level', value: student.level),
              if (student.email.isNotEmpty)
                _DetailRow(icon: Icons.email_rounded, label: 'Email', value: student.email),
              _DetailRow(icon: Icons.person_rounded, label: 'Father', value: student.fatherName),
              if (student.contactNumber.isNotEmpty)
                _DetailRow(icon: Icons.phone_rounded, label: 'Contact', value: student.contactNumber),
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Enrolled',
                value: DateFormat('MMM d, yyyy').format(student.enrollmentDate),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: AppTextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Close',
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 40,
            child: Text(
              _getInitials(student.name),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isDark ? AppColors.darkIcon : AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkBodyText
                          : AppColors.lightBodyText,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkBodyTextSecondary
                          : AppColors.lightBodyTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
