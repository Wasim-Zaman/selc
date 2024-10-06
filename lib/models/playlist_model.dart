class PlaylistModel {
  final String id;
  final String name;
  final List<VideoModel> videos;

  PlaylistModel({required this.id, required this.name, required this.videos});

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'],
      name: json['name'],
      videos: (json['videos'] as List)
          .map((video) => VideoModel.fromJson(video))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'videos': videos.map((video) => video.toJson()).toList(),
    };
  }
}

class VideoModel {
  final String id;
  final String title;
  final String link;

  VideoModel({required this.id, required this.title, required this.link});

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'link': link,
    };
  }
}
