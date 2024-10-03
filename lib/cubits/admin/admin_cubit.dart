import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/models/note.dart';
import 'package:selc/services/notes/notes_service.dart';
import 'package:selc/services/storage/storage_service.dart';

part 'admin_states.dart';

class AdminCubit extends Cubit<AdminState> {
  final NotesService _notesService;
  final StorageService _storageService;

  AdminCubit(this._notesService, this._storageService) : super(AdminInitial());

  Future<void> addCategory(String category) async {
    emit(AdminLoading());
    try {
      await _notesService.addCategory(category);
      emit(AdminSuccess('Category added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteCategory(String category) async {
    emit(AdminLoading());
    try {
      await _notesService.deleteCategory(category);
      emit(AdminSuccess('Category deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> uploadNote(String category, String title, File file) async {
    emit(AdminLoading());
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
      String filePath = 'notes/$category/$fileName';
      String downloadUrl = await _storageService.uploadFile(filePath, file);
      await _notesService.addNote(category, title, downloadUrl);
      emit(AdminSuccess('Note uploaded successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Stream<List<String>> getCategoriesStream() {
    return _notesService.getCategoriesStream();
  }

  Stream<List<Note>> getNotesStream(String category) {
    return _notesService.getNotesStream(category);
  }
}
