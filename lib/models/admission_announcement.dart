import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory AdmissionAnnouncement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AdmissionAnnouncement(
      id: doc.id,
      title: data['title'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      details: data['details'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'details': details,
    };
  }
}
