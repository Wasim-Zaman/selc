import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String url;
  final DateTime timestamp;

  Note({
    required this.id,
    required this.title,
    required this.url,
    required this.timestamp,
  });

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
