import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/models/note.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/note_card.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:gep/view/widgets/app_scaffold.dart';

class AddNotesScreen extends StatelessWidget {
  final String category;

  AddNotesScreen({super.key, required this.category});

  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add Note to $category',
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
                const SizedBox(height: AppConstants.defaultPadding),
                Expanded(
                  child: StreamBuilder<List<Note>>(
                    stream: context.read<AdminCubit>().getNotesStream(category),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return PlaceholderWidgets.listPlaceholder();
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No notes found'));
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            key: Key(snapshot.data![index].id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              _deleteNote(context, snapshot.data![index]);
                            },
                            child: NoteCard(note: snapshot.data![index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _pickAndUploadFile(BuildContext context) async {
    // Single file picking using updated file_picker v12+ API
    final PlatformFile? platformFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (platformFile != null && platformFile.path != null) {
      if (!context.mounted) return;

      final File file = File(platformFile.path!);
      context.read<AdminCubit>().uploadNote(
            category,
            _titleController.text,
            file,
          );
    }
  }

  void _deleteNote(BuildContext context, Note note) {
    context.read<AdminCubit>().deleteNote(category, note.id, note.url);
  }
}
