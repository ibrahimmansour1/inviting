class Book {
  final String id;
  final String languageId;
  final String title;
  final String? description;
  final String? fileUrl;
  final String? coverImageUrl;
  final String? shareableLink;
  final String? createdAt;
  final String? updatedAt;

  Book({
    required this.id,
    required this.languageId,
    required this.title,
    this.description,
    this.fileUrl,
    this.coverImageUrl,
    this.shareableLink,
    this.createdAt,
    this.updatedAt,
  });

  factory Book.fromSupabase(Map<String, dynamic> json) {
    return Book(
      id: json['id'].toString(),
      languageId: json['language_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      fileUrl: json['file_url'],
      coverImageUrl: json['cover_image_url'],
      shareableLink: json['shareable_link'],
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
      'file_url': fileUrl,
      'cover_image_url': coverImageUrl,
      'shareable_link': shareableLink,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Book copyWith({
    String? id,
    String? languageId,
    String? title,
    String? description,
    String? fileUrl,
    String? coverImageUrl,
    String? shareableLink,
    String? createdAt,
    String? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      languageId: languageId ?? this.languageId,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      shareableLink: shareableLink ?? this.shareableLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
