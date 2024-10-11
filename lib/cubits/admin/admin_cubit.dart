import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selc/models/about_me.dart';
import 'package:selc/models/admission_announcement.dart';
import 'package:selc/models/banner.dart';
import 'package:selc/models/course_outline.dart';
import 'package:selc/models/note.dart';
import 'package:selc/models/playlist_model.dart';
import 'package:selc/models/updates.dart';
import 'package:selc/services/about_me/about_me_service.dart';
import 'package:selc/services/admissions/admissions_services.dart';
import 'package:selc/services/banner/banner_service.dart';
import 'package:selc/services/courses_outline/courses_outline_service.dart';
import 'package:selc/services/notes/notes_service.dart';
import 'package:selc/services/playlists/playlist_service.dart';
import 'package:selc/services/storage/storage_service.dart';
import 'package:selc/services/updates/updates_services.dart';

part 'admin_states.dart';

class AdminCubit extends Cubit<AdminState> {
  final NotesService _notesService;
  final StorageService _storageService;
  final CoursesOutlineService _coursesOutlineService;
  final AdmissionsService _admissionsService;
  final PlaylistService _playlistService;
  final BannerService _bannerService;
  final AboutMeService _aboutMeService;
  final UpdatesServices _updatesService;

  AdminCubit(
    this._notesService,
    this._storageService,
    this._coursesOutlineService,
    this._admissionsService,
    this._playlistService,
    this._bannerService,
    this._aboutMeService,
    this._updatesService,
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

  // Banner management methods
  Stream<List<BannerModel>> getBannersStream() {
    return _bannerService.getBannersStream();
  }

  Future<void> addBanner(String title, File imageFile) async {
    emit(AdminLoading());
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = 'banners/$fileName';
      String imageUrl = await _storageService.uploadFile(filePath, imageFile);
      BannerModel banner =
          BannerModel(id: '', title: title, imageUrl: imageUrl);
      await _bannerService.addBanner(banner);
      emit(AdminSuccess('Banner added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updateBanner(BannerModel banner, File? newImageFile) async {
    emit(AdminLoading());
    try {
      String imageUrl = banner.imageUrl;
      if (newImageFile != null) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        String filePath = 'banners/$fileName';
        imageUrl = await _storageService.uploadFile(filePath, newImageFile);
        await _storageService.deleteFile(banner.imageUrl);
      }
      BannerModel updatedBanner = banner.copyWith(imageUrl: imageUrl);
      await _bannerService.updateBanner(banner.id, updatedBanner);
      emit(AdminSuccess('Banner updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    emit(AdminLoading());
    try {
      BannerModel banner = await _bannerService.getBanner(bannerId);
      await _bannerService.deleteBanner(bannerId);
      await _storageService.deleteFile(banner.imageUrl);
      emit(AdminSuccess('Banner deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // About Me management methods
  Future<void> updateAboutMe(AboutMe aboutMe,
      {File? profileImage, File? resume}) async {
    emit(AdminLoading());
    try {
      String? profileImageUrl = aboutMe.profileImageUrl;
      String? resumeUrl = aboutMe.resumeUrl;

      if (profileImage != null) {
        profileImageUrl = await _storageService.uploadFile(
            'profile_images/admin_profile.jpg', profileImage);
      }

      if (resume != null) {
        resumeUrl = await _storageService.uploadFile(
            'resumes/admin_resume.pdf', resume);
      }

      final updatedAboutMe = aboutMe.copyWith(
        profileImageUrl: profileImageUrl,
        resumeUrl: resumeUrl,
      );

      await _aboutMeService.updateAboutMeData(updatedAboutMe);
      emit(AdminSuccess('About Me information updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Stream<AboutMe> getAboutMeStream() {
    return _aboutMeService.getAboutMeStream();
  }

  // Updates management methods
  Stream<List<Updates>> getUpdatesStream() {
    return _updatesService.getUpdatesStream();
  }

  Future<void> addUpdates(Updates update) async {
    emit(AdminLoading());
    try {
      await _updatesService.addUpdate(update);
      emit(AdminSuccess('Update added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updateUpdates(String updateId, Updates update) async {
    emit(AdminLoading());
    try {
      await _updatesService.updateUpdate(updateId, update);
      emit(AdminSuccess('Update modified successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteUpdates(String updateId) async {
    emit(AdminLoading());
    try {
      await _updatesService.deleteUpdate(updateId);
      emit(AdminSuccess('Update deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }
}
