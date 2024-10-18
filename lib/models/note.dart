import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String url;
  final DateTime timestamp;
  final bool accessGranted;

  Note({
    required this.id,
    required this.title,
    required this.url,
    required this.timestamp,
    this.accessGranted = false,
  });

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      accessGranted: map['accessGranted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'timestamp': timestamp,
      'accessGranted': accessGranted,
    };
  }
}
