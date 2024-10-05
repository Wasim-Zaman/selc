import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selc/models/admission_announcement.dart';

class AdmissionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'admission_announcements';

  // Create
  Future<void> addAnnouncement(AdmissionAnnouncement announcement) async {
    try {
      await _firestore.collection(_collection).add(announcement.toMap());
    } catch (e) {
      throw Exception('Failed to add announcement: $e');
    }
  }

  // Read
  Stream<List<AdmissionAnnouncement>> getAnnouncementsStream() {
    return _firestore.collection(_collection).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => AdmissionAnnouncement.fromFirestore(doc))
            .toList();
      },
    );
  }

  // Update
  Future<void> updateAnnouncement(AdmissionAnnouncement announcement) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(announcement.id)
          .update(announcement.toMap());
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  // Delete
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }
}
