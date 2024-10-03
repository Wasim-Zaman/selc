import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selc/models/note.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _categoriesCollection = 'note_categories';

  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(_categoriesCollection).get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<void> addCategory(String category) async {
    try {
      await _firestore.collection(_categoriesCollection).doc(category).set({
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  Future<void> deleteCategory(String category) async {
    try {
      await _firestore.collection(_categoriesCollection).doc(category).delete();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  Stream<List<String>> getCategoriesStream() {
    return _firestore
        .collection(_categoriesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> addNote(String category, String title, String url) async {
    await _firestore.collection('notes').doc(category).collection('files').add({
      'title': title,
      'url': url,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Note>> getNotesStream(String category) {
    return _firestore
        .collection('notes')
        .doc(category)
        .collection('files')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Note.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}
