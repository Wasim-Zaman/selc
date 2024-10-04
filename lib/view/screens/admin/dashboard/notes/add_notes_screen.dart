import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/cubits/admin/admin_cubit.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/snackbars.dart';
import 'package:selc/view/widgets/text_field_widget.dart';

class AddNotesScreen extends StatelessWidget {
  final String category;

  AddNotesScreen({super.key, required this.category});

  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note to $category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is AdminSuccess) {
              TopSnackbar.success(context, state.message);
              _titleController.clear();
            } else if (state is AdminFailure) {
              TopSnackbar.error(context, 'Error: ${state.error}');
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldWidget(
                  controller: _titleController,
                  labelText: 'Note Title',
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ElevatedButton.icon(
                  onPressed: () => _pickAndUploadFile(context),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Select and Upload PDF File'),
                ),
                if (state is AdminLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: AppConstants.defaultPadding),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _pickAndUploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      context.read<AdminCubit>().uploadNote(
            category,
            _titleController.text,
            file,
          );
    }
  }
}