import 'package:flutter/material.dart';
import 'package:selc/models/note.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/view/screens/user/dashboard/notes/pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(note.timestamp.toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () => _viewPdf(context),
            ),
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () => _downloadPdf(),
            ),
          ],
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

  void _downloadPdf() async {
    if (await canLaunch(note.url)) {
      await launch(note.url);
    } else {
      print('Could not launch ${note.url}');
    }
  }
}
