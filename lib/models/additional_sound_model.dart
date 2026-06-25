final class AdditionalSound {
  final String id;
  final String name;
  final String file;
  final String? createdAt;
  final String? createdAtHuman;
  final String? updatedAt;
  final String? updatedAtHuman;

  AdditionalSound({
    required this.id,
    required this.name,
    required this.file,
    this.createdAt,
    this.createdAtHuman,
    this.updatedAt,
    this.updatedAtHuman,
  });

  String get fileName => file.split('/').last;

  factory AdditionalSound.fromSupabase(Map<String, dynamic> json) {
    return AdditionalSound(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      file: json['file_url'] ?? '',
      createdAt: json['created_at'],
      createdAtHuman: json['created_at_human'],
      updatedAt: json['updated_at'],
      updatedAtHuman: json['updated_at_human'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'file_url': file,
      'created_at': createdAt,
      'created_at_human': createdAtHuman,
      'updated_at': updatedAt,
      'updated_at_human': updatedAtHuman,
    };
  }
}
