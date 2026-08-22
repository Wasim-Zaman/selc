import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/models/note.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/view/widgets/note_card.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';

class NotesScreen extends StatelessWidget {
  final String category;

  const NotesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes - $category'),
      ),
      body: StreamBuilder<List<Note>>(
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
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return NoteCard(
                key: Key('Notes Card'),
                note: snapshot.data![index],
              );
            },
          );
        },
      ),
    );
  }
}
