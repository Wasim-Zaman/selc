class AdmissionAnnouncement {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String details;

  AdmissionAnnouncement({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.details,
  });

  factory AdmissionAnnouncement.fromMap(Map<String, dynamic> map) {
    return AdmissionAnnouncement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      startDate: _parseDate(map['startDate']),
      endDate: _parseDate(map['endDate']),
      details: map['details'] ?? '',
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
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'details': details,
    };
  }
}
