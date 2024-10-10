class BannerModel {
  final String id;
  final String title;
  final String imageUrl;

  BannerModel({required this.id, required this.title, required this.imageUrl});

  BannerModel copyWith({String? title, String? imageUrl}) {
    return BannerModel(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory BannerModel.fromMap(Map<String, dynamic> map, String id) {
    return BannerModel(
      id: id,
      title: map['title'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
    };
  }
}
