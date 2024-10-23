import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/course_outline.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/widgets/text_field_widget.dart';

class AddCourseOutlineScreen extends StatefulWidget {
  final Course? courseToEdit;
  const AddCourseOutlineScreen({super.key, this.courseToEdit});

  @override
  State<AddCourseOutlineScreen> createState() => _AddCourseOutlineScreenState();
}

class _AddCourseOutlineScreenState extends State<AddCourseOutlineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseTitle = TextEditingController();
  final List<Week> _weeks = [];
  // Add this line to store text controllers
  final List<List<TextEditingController>> _topicControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      _courseTitle.text = widget.courseToEdit!.title;
      _weeks.addAll(widget.courseToEdit!.weeks);
      // Initialize controllers for existing weeks and topics
      for (var week in _weeks) {
        List<TextEditingController> weekControllers = [
          TextEditingController(text: week.title)
        ];
        weekControllers.addAll(
            week.topics.map((topic) => TextEditingController(text: topic)));
        _topicControllers.add(weekControllers);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Course Outline',
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
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                TextFieldWidget(
                  controller: _courseTitle,
                  labelText: 'Course Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a course title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ..._buildWeeksList(),
                ElevatedButton(
                  onPressed: _addWeek,
                  child: const Text('Add Week'),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ElevatedButton(
                  onPressed: () => _submitCourse(context),
                  child: const Text('Submit Course'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildWeeksList() {
    return _weeks.asMap().entries.map((entry) {
      int idx = entry.key;
      Week week = entry.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week ${idx + 1}',
              style: Theme.of(context).textTheme.titleMedium),
          TextFieldWidget(
            controller: _topicControllers[idx][0],
            labelText: 'Week Title',
            onChanged: (value) {
              setState(() {
                _weeks[idx] = Week(title: value, topics: week.topics);
              });
            },
          ),
          ..._buildTopicsList(idx),
          ElevatedButton(
            onPressed: () => _addTopic(idx),
            child: const Text('Add Topic'),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
        ],
      );
    }).toList();
  }

  List<Widget> _buildTopicsList(int weekIndex) {
    return _weeks[weekIndex].topics.asMap().entries.map((entry) {
      int idx = entry.key;
      return TextFieldWidget(
        controller: _topicControllers[weekIndex][idx + 1],
        labelText: 'Topic ${idx + 1}',
        onChanged: (value) {
          setState(() {
            List<String> updatedTopics = List.from(_weeks[weekIndex].topics);
            updatedTopics[idx] = value;
            _weeks[weekIndex] =
                Week(title: _weeks[weekIndex].title, topics: updatedTopics);
          });
        },
      );
    }).toList();
  }

  void _addWeek() {
    setState(() {
      _weeks.add(Week(title: '', topics: []));
      _topicControllers.add([TextEditingController()]);
    });
  }

  void _addTopic(int weekIndex) {
    setState(() {
      List<String> updatedTopics = List.from(_weeks[weekIndex].topics);
      updatedTopics.add('');
      _weeks[weekIndex] =
          Week(title: _weeks[weekIndex].title, topics: updatedTopics);
      _topicControllers[weekIndex].add(TextEditingController());
    });
  }

  void _submitCourse(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final course = Course(
        id: widget.courseToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _courseTitle.text,
        weeks: _weeks,
      );

      if (widget.courseToEdit != null) {
        context.read<AdminCubit>().updateCourse(course.id!, course);
      } else {
        context.read<AdminCubit>().addCourse(course);
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _courseTitle.dispose();
    for (var controllers in _topicControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
