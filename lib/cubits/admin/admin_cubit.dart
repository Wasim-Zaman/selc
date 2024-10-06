import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/models/admission_announcement.dart';
import 'package:selc/models/course_outline.dart';
import 'package:selc/models/note.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/services/admissions/admissions_services.dart';
import 'package:selc/services/courses_outline/courses_outline_service.dart';
import 'package:selc/services/notes/notes_service.dart';
import 'package:selc/services/storage/storage_service.dart';
import 'package:selc/services/playlists/playlist_service.dart';

part 'admin_states.dart';

class AdminCubit extends Cubit<AdminState> {
  final NotesService _notesService;
  final StorageService _storageService;
  final CoursesOutlineService _coursesOutlineService;
  final AdmissionsService _admissionsService;
  final PlaylistService _playlistService;

  AdminCubit(
    this._notesService,
    this._storageService,
    this._coursesOutlineService,
    this._admissionsService,
    this._playlistService,
  ) : super(AdminInitial());

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
      // Delete the category and all associated notes from Firestore
      await _notesService.deleteCategory(category);

      // Delete the entire folder for the category from Firebase Storage
      await _storageService.deleteFolder('notes/$category');

      emit(AdminSuccess(
          'Category and all associated notes deleted successfully'));
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

  Future<void> deleteNote(
      String category, String noteId, String fileUrl) async {
    emit(AdminLoading());
    try {
      await _notesService.deleteNote(category, noteId);
      await _storageService.deleteFile(fileUrl);
      emit(AdminSuccess('Note deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // Courses Outlines
  Stream<List<Course>> getCoursesStream() {
    return _coursesOutlineService.getCoursesStream();
  }

  Future<void> addCourse(Course course) async {
    emit(AdminLoading());
    try {
      await _coursesOutlineService.addCourse(course);
      emit(AdminSuccess('Course added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updateCourse(String courseId, Course course) async {
    emit(AdminLoading());
    try {
      await _coursesOutlineService.updateCourse(courseId, course);
      emit(AdminSuccess('Course updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteCourse(String courseId) async {
    emit(AdminLoading());
    try {
      await _coursesOutlineService.deleteCourse(courseId);
      emit(AdminSuccess('Course deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // Admissions
  Stream<List<AdmissionAnnouncement>> getAdmissionAnnouncementsStream() {
    return _admissionsService.getAnnouncementsStream();
  }

  Future<void> addAdmissionAnnouncement(
      AdmissionAnnouncement announcement) async {
    emit(AdminLoading());
    try {
      await _admissionsService.addAnnouncement(announcement);
      emit(AdminSuccess('Announcement added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updateAdmissionAnnouncement(
      AdmissionAnnouncement announcement) async {
    emit(AdminLoading());
    try {
      await _admissionsService.updateAnnouncement(announcement);
      emit(AdminSuccess('Announcement updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteAdmissionAnnouncement(String id) async {
    emit(AdminLoading());
    try {
      await _admissionsService.deleteAnnouncement(id);
      emit(AdminSuccess('Announcement deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // Playlists
  Stream<List<PlaylistModel>> getPlaylistsStream() {
    return _playlistService.getPlaylistsStream();
  }

  Future<void> addPlaylist(PlaylistModel playlist) async {
    emit(AdminLoading());
    try {
      await _playlistService.addPlaylist(playlist);
      emit(AdminSuccess('Playlist added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updatePlaylist(String playlistId, PlaylistModel playlist) async {
    emit(AdminLoading());
    try {
      await _playlistService.updatePlaylist(playlistId, playlist);
      emit(AdminSuccess('Playlist updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    emit(AdminLoading());
    try {
      await _playlistService.deletePlaylist(playlistId);
      emit(AdminSuccess('Playlist deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> addVideoToPlaylist(String playlistId, VideoModel video) async {
    emit(AdminLoading());
    try {
      await _playlistService.addVideoToPlaylist(playlistId, video);
      emit(AdminSuccess('Video added to playlist successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> removeVideoFromPlaylist(
      String playlistId, String videoId) async {
    emit(AdminLoading());
    try {
      await _playlistService.removeVideoFromPlaylist(playlistId, videoId);
      emit(AdminSuccess('Video removed from playlist successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }
}
