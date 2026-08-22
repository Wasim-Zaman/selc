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
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: _parseDate(map['date']),
      type: UpdateType.values
          .firstWhere((e) => e.toString() == 'UpdateType.${map['type']}'),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

enum UpdateType { newCourse, event, resourceUpdate }
