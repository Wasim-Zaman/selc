import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YouTubeChannelScreen extends StatefulWidget {
  const YouTubeChannelScreen({super.key});

  @override
  State<YouTubeChannelScreen> createState() => _YouTubeChannelScreenState();
}

class _YouTubeChannelScreenState extends State<YouTubeChannelScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://youtube.com/@saniacademy?si=koFrp6DPHLu2hUkk'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Channel'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}