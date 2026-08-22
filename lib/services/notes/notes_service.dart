import 'dart:developer';

import 'package:gep/models/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _categoriesTable = 'note_categories';
  final String _notesTable = 'notes';

  Future<List<String>> getCategories() async {
    try {
      final data = await _supabase.from(_categoriesTable).select('id');
      return data.map<String>((row) => row['id'] as String).toList();
    } catch (e) {
      log('Error getting categories: $e');
      return [];
    }
  }

  Future<void> addCategory(String category) async {
    try {
      await _supabase.from(_categoriesTable).insert({
        'id': category,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      log('Error adding category: $e');
    }
  }

  Future<void> deleteCategory(String category) async {
    try {
      // Delete all notes in the category
      await _supabase.from(_notesTable).delete().eq('category_id', category);

      // Delete the category itself
      await _supabase.from(_categoriesTable).delete().eq('id', category);
    } catch (e) {
      log('Error deleting category: $e');
      rethrow;
    }
  }

  Stream<List<String>> getCategoriesStream() {
    return _supabase
        .from(_categoriesTable)
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((row) => row['id'] as String).toList());
  }

  Future<void> addNote(String category, String title, String url) async {
    await _supabase.from(_notesTable).insert({
      'category_id': category,
      'title': title,
      'url': url,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteNote(String category, String noteId) async {
    await _supabase.from(_notesTable).delete().eq('id', noteId);
  }

  Stream<List<Note>> getNotesStream(String category) {
    return _supabase
        .from(_notesTable)
        .stream(primaryKey: ['id'])
        .eq('category_id', category)
        .map((rows) {
      final notes = rows
          .map((row) => Note.fromMap(row['id'] as String, {
                'title': row['title'],
                'url': row['url'],
                'timestamp': row['timestamp'],
                'accessGranted': row['access_granted'] ?? false,
              }))
          .toList();
      notes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return notes;
    });
  }
}
