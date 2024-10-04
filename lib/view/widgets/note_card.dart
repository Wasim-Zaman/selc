import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selc/models/note.dart';
import 'package:selc/utils/constants.dart';
import 'package:selc/utils/navigation.dart';
import 'package:selc/view/screens/user/dashboard/notes/pdf_viewer_screen.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: () => _viewPdf(context),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultRadius / 2),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added on ${DateFormat('MMM d, yyyy').format(note.timestamp)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: () => _viewPdf(context),
                tooltip: 'View PDF',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewPdf(BuildContext context) {
    Navigations.push(
      context,
      PdfViewerScreen(pdfUrl: note.url, title: note.title),
    );
  }
}
