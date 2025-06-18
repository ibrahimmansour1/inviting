class AdditionalSound {
  final int id;
  final String name;
  final String file;
  final String createdAt;
  final String createdAtHuman;
  final String updatedAt;
  final String updatedAtHuman;

  AdditionalSound({
    required this.id,
    required this.name,
    required this.file,
    required this.createdAt,
    required this.createdAtHuman,
    required this.updatedAt,
    required this.updatedAtHuman,
  });

  // Get the filename for the additional sound
  String get fileName => file.split('/').last;

  // JSON serialization
  factory AdditionalSound.fromJson(Map<String, dynamic> json) {
    return AdditionalSound(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      file: json['file'] ?? '',
      createdAt: json['created_at'] ?? '',
      createdAtHuman: json['created_at_human'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      updatedAtHuman: json['updated_at_human'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file': file,
      'created_at': createdAt,
      'created_at_human': createdAtHuman,
      'updated_at': updatedAt,
      'updated_at_human': updatedAtHuman,
    };
  }
}
