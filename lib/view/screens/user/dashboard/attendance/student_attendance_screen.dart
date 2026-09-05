import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/student_attendance/student_attendance_cubit.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final String studentId;
  const StudentAttendanceScreen({super.key, required this.studentId});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  int _viewMode = 0; // 0 = monthly, 1 = weekly

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context
        .read<StudentAttendanceCubit>()
        .loadMonthly(widget.studentId, now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return AppScaffold(
      title: 'My Attendance',
      body: BlocBuilder<StudentAttendanceCubit, StudentAttendanceState>(
        builder: (context, state) {
          if (state.isLoading && state.dailyRecords.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Summary Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.defaultPadding),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.secondary.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Present',
                            value:
                                '${state.summary['present_days'] ?? 0}',
                            color: AppColors.success,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: borderColor,
                          ),
                          _StatItem(
                            label: 'Total',
                            value:
                                '${state.summary['total_days'] ?? 0}',
                            color: AppColors.info,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: borderColor,
                          ),
                          _StatItem(
                            label: 'Rate',
                            value:
                                '${state.summary['percentage'] ?? 0}%',
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: ((state.summary['percentage'] ?? 0) as num) /
                              100,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // View Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('Monthly'),
                        icon: Icon(Icons.calendar_month_rounded),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('Weekly'),
                        icon: Icon(Icons.view_week_rounded),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (set) {
                      if (set.isEmpty) return;
                      setState(() => _viewMode = set.first);
                      final cubit = context.read<StudentAttendanceCubit>();
                      if (_viewMode == 0) {
                        cubit.loadMonthly(
                            widget.studentId, state.year, state.month);
                      } else {
                        final now = DateTime.now();
                        final weekStart =
                            now.subtract(Duration(days: now.weekday - 1));
                        cubit.loadWeekly(widget.studentId, weekStart);
                      }
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Month navigator (only for monthly view)
              if (_viewMode == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () {
                            context
                                .read<StudentAttendanceCubit>()
                                .previousMonth();
                            final cubit =
                                context.read<StudentAttendanceCubit>();
                            cubit.loadMonthly(widget.studentId, cubit.state.year,
                                cubit.state.month);
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy')
                              .format(DateTime(state.year, state.month)),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () {
                            context.read<StudentAttendanceCubit>().nextMonth();
                            final cubit =
                                context.read<StudentAttendanceCubit>();
                            cubit.loadMonthly(widget.studentId, cubit.state.year,
                                cubit.state.month);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Calendar Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < 7) {
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Center(
                          child: Text(
                            days[index],
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkBodyTextSecondary
                                  : AppColors.lightBodyTextSecondary,
                            ),
                          ),
                        );
                      }

                      final dayIndex = index - 7;
                      if (dayIndex >= state.dailyRecords.length) {
                        return const SizedBox.shrink();
                      }

                      final record = state.dailyRecords[dayIndex];
                      final date = DateTime.tryParse(
                              record['date']?.toString() ?? '') ??
                          DateTime.now();
                      final isPresent = record['is_present'] == true;
                      final isToday = DateTime.now().year == date.year &&
                          DateTime.now().month == date.month &&
                          DateTime.now().day == date.day;

                      return Container(
                        decoration: BoxDecoration(
                          color: isPresent
                              ? AppColors.success.withValues(alpha: 0.15)
                              : isToday
                                  ? AppColors.accent.withValues(alpha: 0.1)
                                  : cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday
                                ? AppColors.accent
                                : borderColor,
                            width: isToday ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isPresent
                                      ? AppColors.success
                                      : null,
                                ),
                              ),
                              if (isPresent)
                                Icon(
                                  Icons.check_rounded,
                                  size: 10,
                                  color: AppColors.success,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: 7 + state.dailyRecords.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
