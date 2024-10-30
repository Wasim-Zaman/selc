import 'dart:developer';

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
      log('Error getting categories: $e');
      return [];
    }
  }

  Future<void> addCategory(String category) async {
    try {
      await _firestore.collection(_categoriesCollection).doc(category).set({
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error adding category: $e');
    }
  }

  Future<List<String>> deleteCategory(String category) async {
    try {
      // Get all notes in the category
      final notesSnapshot = await _firestore
          .collection('notes')
          .doc(category)
          .collection('files')
          .get();

      // Delete all notes in the category from Firestore
      final batch = _firestore.batch();
      for (var doc in notesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete the category document
      await _firestore.collection(_categoriesCollection).doc(category).delete();

      // Delete the notes collection for the category
      await _firestore.collection('notes').doc(category).delete();

      // Return the list of file paths to be deleted from storage
      return notesSnapshot.docs
          .map((doc) => 'notes/$category/${doc.id}.pdf')
          .toList();
    } catch (e) {
      log('Error deleting category: $e');
      rethrow;
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

  Future<void> deleteNote(String category, String noteId) async {
    await _firestore
        .collection('notes')
        .doc(category)
        .collection('files')
        .doc(noteId)
        .delete();
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
