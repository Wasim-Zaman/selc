import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selc/models/updates.dart';

class UpdatesServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'updates';

  Stream<List<Updates>> getUpdatesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Updates.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addUpdate(Updates update) async {
    await _firestore.collection(_collection).add(update.toMap());
  }

  Future<void> updateUpdate(String updateId, Updates update) async {
    await _firestore
        .collection(_collection)
        .doc(updateId)
        .update(update.toMap());
  }

  Future<void> deleteUpdate(String updateId) async {
    await _firestore.collection(_collection).doc(updateId).delete();
  }
}
