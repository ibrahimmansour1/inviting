class Video {
  final String id;
  final String languageId;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? shareableLink;
  final int? durationSeconds;
  final String? createdAt;
  final String? updatedAt;

  Video({
    required this.id,
    required this.languageId,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.shareableLink,
    this.durationSeconds,
    this.createdAt,
    this.updatedAt,
  });

  factory Video.fromSupabase(Map<String, dynamic> json) {
    return Video(
      id: json['id'].toString(),
      languageId: json['language_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      shareableLink: json['shareable_link'],
      durationSeconds: json['duration_seconds'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language_id': languageId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'shareable_link': shareableLink,
      'duration_seconds': durationSeconds,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Video copyWith({
    String? id,
    String? languageId,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    String? shareableLink,
    int? durationSeconds,
    String? createdAt,
    String? updatedAt,
  }) {
    return Video(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      shareableLink: shareableLink ?? this.shareableLink,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedDuration {
    if (durationSeconds == null) return '';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
