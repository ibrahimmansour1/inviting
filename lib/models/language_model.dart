import 'additional_sound_model.dart';

class Language {
  final String? id; // Add id field for backend integration
  final String name;
  final String nativeName;
  final String flagPath;
  final String audioPath;
  final bool isLocal; // True if audio is bundled with app, false if remote
  final String? remoteAudioFileName; // Filename for remote audio
  final int? additionalSoundsCount;
  final List<AdditionalSound>? additionalSounds;
  final String? createdAt;
  final String? createdAtHuman;
  final String? updatedAt;
  final String? updatedAtHuman;

  Language({
    this.id,
    required this.name,
    required this.nativeName,
    required this.flagPath,
    required this.audioPath,
    this.isLocal = false,
    this.remoteAudioFileName,
    this.additionalSoundsCount,
    this.additionalSounds,
    this.createdAt,
    this.createdAtHuman,
    this.updatedAt,
    this.updatedAtHuman,
  });

  // Get the filename for remote audio
  String get audioFileName {
    if (remoteAudioFileName != null) {
      return remoteAudioFileName!;
    }
    // Extract filename from audioPath
    return audioPath.split('/').last;
  }

  // JSON serialization
  factory Language.fromJson(Map<String, dynamic> json) {
    List<AdditionalSound>? additionalSounds;
    if (json['additional_sounds'] != null) {
      additionalSounds = (json['additional_sounds'] as List)
          .map((soundJson) => AdditionalSound.fromJson(soundJson))
          .toList();
    }

    return Language(
      id: json['_id'] ?? json['id']?.toString(),
      name: json['english_name'] ?? json['name'] ?? '',
      nativeName: json['native_name'] ?? json['nativeName'] ?? '',
      flagPath: json['flag'] ?? json['flagPath'] ?? '',
      audioPath: json['sound'] ?? json['audioPath'] ?? '',
      isLocal: json['isLocal'] ?? false,
      remoteAudioFileName: json['remoteAudioFileName'],
      additionalSoundsCount: json['additional_sounds_count'],
      additionalSounds: additionalSounds,
      createdAt: json['created_at'],
      createdAtHuman: json['created_at_human'],
      updatedAt: json['updated_at'],
      updatedAtHuman: json['updated_at_human'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english_name': name,
      'native_name': nativeName,
      'flag': flagPath,
      'sound': audioPath,
      'isLocal': isLocal,
      'remoteAudioFileName': remoteAudioFileName,
      if (additionalSoundsCount != null)
        'additional_sounds_count': additionalSoundsCount,
      if (additionalSounds != null)
        'additional_sounds':
            additionalSounds!.map((sound) => sound.toJson()).toList(),
    };
  }

  // Create a copy with updated fields
  Language copyWith({
    String? id,
    String? name,
    String? nativeName,
    String? flagPath,
    String? audioPath,
    bool? isLocal,
    String? remoteAudioFileName,
    int? additionalSoundsCount,
    List<AdditionalSound>? additionalSounds,
    String? createdAt,
    String? createdAtHuman,
    String? updatedAt,
    String? updatedAtHuman,
  }) {
    return Language(
      id: id ?? this.id,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      flagPath: flagPath ?? this.flagPath,
      audioPath: audioPath ?? this.audioPath,
      isLocal: isLocal ?? this.isLocal,
      remoteAudioFileName: remoteAudioFileName ?? this.remoteAudioFileName,
      additionalSoundsCount:
          additionalSoundsCount ?? this.additionalSoundsCount,
      additionalSounds: additionalSounds ?? this.additionalSounds,
      createdAt: createdAt ?? this.createdAt,
      createdAtHuman: createdAtHuman ?? this.createdAtHuman,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedAtHuman: updatedAtHuman ?? this.updatedAtHuman,
    );
  }
}
