import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/models/course_outline.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_delete_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_text_button.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class ManageCoursesScreen extends StatelessWidget {
  const ManageCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppColors.darkScaffoldBackground
        : AppColors.lightScaffoldBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return AppScaffold(
      backgroundColor: backgroundColor,
      title: 'Manage Courses',
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminSuccess) {
            TopSnackbar.success(context, state.message);
          } else if (state is AdminFailure) {
            TopSnackbar.error(context, state.error);
          }
        },
        builder: (context, state) {
          return StreamBuilder<List<Course>>(
            stream: context.read<AdminCubit>().getCoursesStream(),
            builder: (context, snapshot) {
              final courses = snapshot.data ?? [];
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.defaultPadding + 4,
                        12,
                        AppConstants.defaultPadding + 4,
                        8,
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
                                'AVAILABLE COURSES',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (!isLoading && courses.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkNeutral
                                    : AppColors.lightNeutral,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${courses.length}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkBodyText
                                      : AppColors.lightBodyText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),
                  if (isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: PlaceholderWidgets.listPlaceholder(),
                      ),
                    )
                  else if (snapshot.hasError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load courses',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${snapshot.error}',
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
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkNeutral
                                    : AppColors.lightNeutral,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 36,
                                color: textColorSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Courses Found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap the + button below to add your first course',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: textColorSecondary,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final course = courses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.02,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () =>
                                      _showCourseSheet(context, course: course),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.darkNeutral
                                                : AppColors.lightNeutral,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.auto_stories_rounded,
                                            size: 22,
                                            color: isDark
                                                ? AppColors.darkIcon
                                                : AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course.title,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    size: 12,
                                                    color: textColorSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${course.weeks.length} weeks duration',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              textColorSecondary,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            color: isDark
                                                ? AppColors.darkIcon
                                                : AppColors.primary,
                                            size: 20,
                                          ),
                                          onPressed: () => _showCourseSheet(
                                            context,
                                            course: course,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.error.withValues(
                                              alpha: 0.85,
                                            ),
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _deleteCourse(context, course),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: (30 + index * 20).ms).slideY(begin: 0.05, end: 0),
                          );
                        }, childCount: courses.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showCourseSheet(context),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Add Course',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  void _showCourseSheet(BuildContext context, {Course? course}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // take 60 percent of the screen height
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: _CourseSheet(course: course),
      ),
    );
  }

  void _deleteCourse(BuildContext context, Course course) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text('Delete Course'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${course.title}"?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkBodyTextSecondary
                  : AppColors.lightBodyTextSecondary,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: <Widget>[
            AppTextButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            AppDeleteButton(
              label: 'Delete',
              onPressed: () {
                context.read<AdminCubit>().deleteCourse(course.id!);
                Navigator.of(dialogContext).pop();
              },
              expanded: false,
              height: null,
              borderRadius: 12,
            ),
          ],
        );
      },
    );
  }
}

class _CourseSheet extends StatefulWidget {
  final Course? course;
  const _CourseSheet({this.course});

  @override
  State<_CourseSheet> createState() => _CourseSheetState();
}

class _CourseSheetState extends State<_CourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _courseTitle = TextEditingController();
  final List<Week> _weeks = [];
  final List<List<TextEditingController>> _topicControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _courseTitle.text = widget.course!.title;
      _weeks.addAll(widget.course!.weeks);
      for (var week in _weeks) {
        final controllers = <TextEditingController>[
          TextEditingController(text: week.title),
        ];
        controllers.addAll(
          week.topics.map((t) => TextEditingController(text: t)),
        );
        _topicControllers.add(controllers);
      }
    }
  }

  @override
  void dispose() {
    _courseTitle.dispose();
    for (var list in _topicControllers) {
      for (var c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              widget.course == null ? 'Add Course' : 'Edit Course',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                TextFieldWidget(
                  controller: _courseTitle,
                  labelText: 'Course Title',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter course title' : null,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ..._buildWeeksList(isDark, cardColor, borderColor),
                const SizedBox(height: 12),
                _ActionChip(
                  icon: Icons.add_rounded,
                  label: 'Add Week',
                  onTap: _addWeek,
                ),
                const SizedBox(height: AppConstants.defaultPadding * 2),
                AppButton(
                  label: widget.course == null
                      ? 'Create Course'
                      : 'Save Changes',
                  onPressed: _submit,
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWeeksList(
    bool isDark,
    Color cardColor,
    Color borderColor,
  ) {
    return _weeks.asMap().entries.map((entry) {
      final idx = entry.key;
      final week = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Week ${idx + 1}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (_weeks.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error.withValues(alpha: 0.85),
                      size: 18,
                    ),
                    onPressed: () => _removeWeek(idx),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFieldWidget(
              controller: _topicControllers[idx][0],
              labelText: 'Week Title',
              onChanged: (v) =>
                  _weeks[idx] = Week(title: v, topics: week.topics),
            ),
            const SizedBox(height: 12),
            ..._buildTopicsList(idx),
            const SizedBox(height: 8),
            _ActionChip(
              icon: Icons.add_rounded,
              label: 'Add Topic',
              onTap: () => _addTopic(idx),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildTopicsList(int weekIndex) {
    return _weeks[weekIndex].topics.asMap().entries.map((entry) {
      final idx = entry.key;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFieldWidget(
                controller: _topicControllers[weekIndex][idx + 1],
                labelText: 'Topic ${idx + 1}',
                onChanged: (v) {
                  final updated = List<String>.from(_weeks[weekIndex].topics);
                  updated[idx] = v;
                  _weeks[weekIndex] = Week(
                    title: _weeks[weekIndex].title,
                    topics: updated,
                  );
                },
              ),
            ),
            if (_weeks[weekIndex].topics.length > 1)
              IconButton(
                icon: Icon(
                  Icons.remove_circle_outline_rounded,
                  color: AppColors.error.withValues(alpha: 0.7),
                  size: 20,
                ),
                onPressed: () => _removeTopic(weekIndex, idx),
              ),
          ],
        ),
      );
    }).toList();
  }

  void _addWeek() {
    setState(() {
      _weeks.add(Week(title: '', topics: ['']));
      _topicControllers.add([TextEditingController(), TextEditingController()]);
    });
  }

  void _removeWeek(int index) {
    setState(() {
      for (var c in _topicControllers[index]) {
        c.dispose();
      }
      _topicControllers.removeAt(index);
      _weeks.removeAt(index);
    });
  }

  void _addTopic(int weekIndex) {
    setState(() {
      final updated = List<String>.from(_weeks[weekIndex].topics)..add('');
      _weeks[weekIndex] = Week(title: _weeks[weekIndex].title, topics: updated);
      _topicControllers[weekIndex].add(TextEditingController());
    });
  }

  void _removeTopic(int weekIndex, int topicIndex) {
    setState(() {
      _topicControllers[weekIndex][topicIndex + 1].dispose();
      _topicControllers[weekIndex].removeAt(topicIndex + 1);
      final updated = List<String>.from(_weeks[weekIndex].topics)
        ..removeAt(topicIndex);
      _weeks[weekIndex] = Week(title: _weeks[weekIndex].title, topics: updated);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final course = Course(
      id: widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _courseTitle.text,
      weeks: _weeks,
    );
    if (widget.course != null) {
      context.read<AdminCubit>().updateCourse(course.id!, course);
    } else {
      context.read<AdminCubit>().addCourse(course);
    }
    Navigator.pop(context);
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
