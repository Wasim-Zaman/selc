import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/course_outline.dart';
import 'package:selc/router/app_navigation.dart';
import 'package:selc/router/app_routes.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/widgets/placeholder_widget.dart';

class ManageCoursesScreen extends StatelessWidget {
  const ManageCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Courses',
            style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return PlaceholderWidgets.listPlaceholder();
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No courses found'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final course = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: ListTile(
                      title: Text(
                        course.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${course.weeks.length} weeks',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: theme.colorScheme.primary),
                            onPressed: () => _editCourse(context, course),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: theme.colorScheme.error),
                            onPressed: () => _deleteCourse(context, course),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppNavigation.push(
          context,
          AppRoutes.kAddCourseOutlineRoute,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editCourse(BuildContext context, Course course) {
    // Navigate to edit course screen
    AppNavigation.push(context, AppRoutes.kAddCourseOutlineRoute,
        extra: course);
  }

  void _deleteCourse(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                context.read<AdminCubit>().deleteCourse(course.id!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
