import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FullScreenResumeScreen extends StatelessWidget {
  final String resumeUrl;

  const FullScreenResumeScreen({Key? key, required this.resumeUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SfPdfViewer.network(
        resumeUrl,
        enableDoubleTapZooming: true,
      ),
    );
  }
}
