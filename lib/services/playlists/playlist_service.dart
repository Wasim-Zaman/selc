import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selc/models/playlist_model.dart';

class PlaylistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'playlists';

  Stream<List<PlaylistModel>> getPlaylistsStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        List<VideoModel> videos = (data['videos'] as List).map((videoData) {
          return VideoModel(
            id: videoData['id'],
            title: videoData['title'],
            link: videoData['link'],
          );
        }).toList();

        return PlaylistModel(
          id: doc.id,
          name: data['name'],
          videos: videos,
        );
      }).toList();
    });
  }

  Future<void> addPlaylist(PlaylistModel playlist) async {
    await _firestore.collection(_collection).add({
      'name': playlist.name,
      'videos': playlist.videos.map((video) => video.toJson()).toList(),
    });
  }

  Future<void> updatePlaylist(String playlistId, PlaylistModel playlist) async {
    await _firestore.collection(_collection).doc(playlistId).update({
      'name': playlist.name,
      'videos': playlist.videos.map((video) => video.toJson()).toList(),
    });
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _firestore.collection(_collection).doc(playlistId).delete();
  }

  Future<void> addVideoToPlaylist(String playlistId, VideoModel video) async {
    await _firestore.collection(_collection).doc(playlistId).update({
      'videos': FieldValue.arrayUnion([video.toJson()]),
    });
  }

  Future<void> removeVideoFromPlaylist(
      String playlistId, String videoId) async {
    final playlistDoc =
        await _firestore.collection(_collection).doc(playlistId).get();
    final playlist = PlaylistModel.fromJson(playlistDoc.data()!);

    final updatedVideos =
        playlist.videos.where((v) => v.id != videoId).toList();

    await _firestore.collection(_collection).doc(playlistId).update({
      'videos': updatedVideos.map((video) => video.toJson()).toList(),
    });
  }
}
