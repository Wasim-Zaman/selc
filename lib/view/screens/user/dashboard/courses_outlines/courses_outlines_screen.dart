import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/user_courses/user_courses_cubit.dart';
import 'package:gep/cubits/user_courses/user_courses_state.dart';
import 'package:gep/models/course_outline.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class CoursesOutlinesScreen extends StatefulWidget {
  const CoursesOutlinesScreen({super.key});

  @override
  State<CoursesOutlinesScreen> createState() => _CoursesOutlinesScreenState();
}

class _CoursesOutlinesScreenState extends State<CoursesOutlinesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<UserCoursesCubit>().fetchPage(0);
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
      title: 'Courses & Outlines',
      body: BlocBuilder<UserCoursesCubit, UserCoursesState>(
        builder: (context, state) {
          final courses = state.items;
          final isLoading = state.isLoading && courses.isEmpty;

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<UserCoursesCubit>().refresh(),
            child: CustomScrollView(
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
                      labelText: 'Search courses',
                      hintText: 'Search courses…',
                      prefixIcon: Icons.search_rounded,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon:
                                  const Icon(Icons.close_rounded, size: 18),
                              color: textColorSecondary,
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<UserCoursesCubit>()
                                    .clearSearch();
                              },
                            )
                          : null,
                      onChanged: (v) => context
                          .read<UserCoursesCubit>()
                          .setSearchQuery(v),
                    ),
                  ),
                ),

                // Header Label & Badge
                if (!isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.defaultPadding,
                        0,
                        AppConstants.defaultPadding,
                        12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 16,
                                color: textColorSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.searchQuery.isEmpty
                                    ? 'AVAILABLE COURSES'
                                    : 'SEARCH RESULTS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (courses.isNotEmpty)
                            Badge(
                              label: Text('${courses.length}'),
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
                  ),

                if (isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: PlaceholderWidgets.listPlaceholder(),
                    ),
                  )
                else if (state.error != null && courses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load courses',
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
                else if (courses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 36,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'No courses found'
                                : 'No matches for "${state.searchQuery}"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'Check back later for new courses'
                                : '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColorSecondary,
                            ),
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CourseCard(
                            course: courses[index],
                            index: index,
                            cardColor: cardColor,
                            borderColor: borderColor,
                          ),
                        );
                      }, childCount: courses.length),
                    ),
                  ),

                // Pagination
                if (courses.isNotEmpty)
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
                            context.read<UserCoursesCubit>().previousPage(),
                        onNext: () =>
                            context.read<UserCoursesCubit>().nextPage(),
                        onPageSelected: (page) =>
                            context.read<UserCoursesCubit>().goToPage(page),
                        onRefresh: () =>
                            context.read<UserCoursesCubit>().refresh(),
                        currentPage: state.currentPage,
                        pageSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final int index;
  final Color cardColor;
  final Color borderColor;

  const _CourseCard({
    required this.course,
    required this.index,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            course.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${course.weeks.length} weeks',
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColorSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: course.weeks.length,
              itemBuilder: (context, weekIndex) {
                return _WeekTile(week: course.weeks[weekIndex]);
              },
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (30 + index * 20).ms)
        .slideY(begin: 0.05, end: 0);
  }
}

class _WeekTile extends StatelessWidget {
  final Week week;

  const _WeekTile({required this.week});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Text(
          week.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: week.topics.map((topic) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 40),
            title: Text(
              topic,
              style: theme.textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.check_circle_outline,
              size: 18,
              color: isDark ? AppColors.darkIcon : AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }
}
