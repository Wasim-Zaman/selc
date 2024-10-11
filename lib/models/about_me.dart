class AboutMe {
  final String? profileImageUrl;
  final double latitude;
  final double longitude;
  final String youtubeChannelLink;
  final String? resumeUrl;

  AboutMe({
    this.profileImageUrl,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.youtubeChannelLink = '',
    this.resumeUrl,
  });

  factory AboutMe.fromMap(Map<String, dynamic> map) {
    return AboutMe(
      profileImageUrl: map['profileImageUrl'],
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      youtubeChannelLink: map['youtubeChannelLink'] ?? '',
      resumeUrl: map['resumeUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileImageUrl': profileImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'youtubeChannelLink': youtubeChannelLink,
      'resumeUrl': resumeUrl,
    };
  }

  AboutMe copyWith({
    String? profileImageUrl,
    double? latitude,
    double? longitude,
    String? youtubeChannelLink,
    String? resumeUrl,
  }) {
    return AboutMe(
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      youtubeChannelLink: youtubeChannelLink ?? this.youtubeChannelLink,
      resumeUrl: resumeUrl ?? this.resumeUrl,
    );
  }
}
