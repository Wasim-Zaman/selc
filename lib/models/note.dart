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
      timestamp: _parseDate(map['timestamp']),
      accessGranted: map['accessGranted'] ?? false,
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
      'url': url,
      'timestamp': timestamp.toIso8601String(),
      'accessGranted': accessGranted,
    };
  }
}
