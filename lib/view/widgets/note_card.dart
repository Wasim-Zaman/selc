import 'package:flutter/material.dart';
import 'package:selc/models/note.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/view/screens/user/dashboard/notes/pdf_viewer_screen.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(note.timestamp.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.remove_red_eye),
          onPressed: () => _viewPdf(context),
        ),
      ),
    );
  }

  void _viewPdf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PdfViewerScreen(pdfUrl: note.url, title: note.title),
      ),
    );
  }
}
