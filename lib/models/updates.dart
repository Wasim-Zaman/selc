import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Updates {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final UpdateType type;

  Updates({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });

  String get formattedDate => DateFormat('MMM d, yyyy').format(date);

  factory Updates.fromMap(Map<String, dynamic> map, String id) {
    return Updates(
      id: id,
      title: map['title'],
      description: map['description'],
      date: (map['date'] as Timestamp).toDate(),
      type: UpdateType.values
          .firstWhere((e) => e.toString() == 'UpdateType.${map['type']}'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type.toString().split('.').last,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

enum UpdateType { newCourse, event, resourceUpdate }
