import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/models/updates.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/widgets/text_field_widget.dart';

class UpdatesManagementScreen extends StatefulWidget {
  const UpdatesManagementScreen({Key? key}) : super(key: key);

  @override
  _UpdatesManagementScreenState createState() =>
      _UpdatesManagementScreenState();
}

class _UpdatesManagementScreenState extends State<UpdatesManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  UpdateType _selectedType = UpdateType.newCourse;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Updates Management')),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminSuccess) {
            TopSnackbar.success(context, state.message);
            _resetForm();
          } else if (state is AdminFailure) {
            TopSnackbar.error(context, 'Error: ${state.error}');
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<Updates>>(
            stream: context.read<AdminCubit>().getUpdatesStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final updates = snapshot.data!;

              if (updates.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No updates available',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showUpdateDialog(context, null),
                        child: const Text('Add New Update'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: updates.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final update = updates[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: AppConstants.defaultPadding,
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
                            onPressed: () => _showUpdateDialog(context, update),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: theme.colorScheme.error),
                            onPressed: () => _confirmDelete(context, update.id),
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
                    value: _selectedType,
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
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(update == null ? 'Add' : 'Update'),
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
                    context.read<AdminCubit>().addUpdates(newUpdate);
                  } else {
                    context
                        .read<AdminCubit>()
                        .updateUpdates(update.id, newUpdate);
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
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      context.read<AdminCubit>().deleteUpdates(updateId);
    }
  }
}
