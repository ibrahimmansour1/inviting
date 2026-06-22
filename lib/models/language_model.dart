import 'additional_sound_model.dart';

class Language {
  final String? id;
  final String name;
  final String nativeName;
  final String flagPath;
  final String audioPath;
  final bool isLocal;
  final String? remoteAudioFileName;
  final int? additionalSoundsCount;
  final List<AdditionalSound>? additionalSounds;
  final String? createdAt;
  final String? createdAtHuman;
  final String? updatedAt;
  final String? updatedAtHuman;
  final String? motivationalText;
  final int? personNum;
  final String? qrDescription;

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
    this.motivationalText,
    this.personNum,
    this.qrDescription,
  });

  String get audioFileName {
    if (remoteAudioFileName != null) {
      return remoteAudioFileName!;
    }
    return audioPath.split('/').last;
  }

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
    String? motivationalText,
    int? personNum,
    String? qrDescription,
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
      motivationalText: motivationalText ?? this.motivationalText,
      personNum: personNum ?? this.personNum,
      qrDescription: qrDescription ?? this.qrDescription,
    );
  }

  factory Language.fromSupabase(Map<String, dynamic> json) {
    final soundsList = json['additional_sounds'] as List?;
    final parsedSounds = soundsList != null
        ? soundsList
            .map((e) => AdditionalSound.fromSupabase(e as Map<String, dynamic>))
            .toList()
        : <AdditionalSound>[];

    return Language(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      nativeName: json['native_name'] ?? '',
      flagPath: json['flag_url'] ?? '',
      audioPath: json['audio_url'] ?? '',
      isLocal: json['is_local'] ?? false,
      remoteAudioFileName: json['remote_audio_filename'],
      additionalSoundsCount:
          parsedSounds.isNotEmpty ? parsedSounds.length : null,
      additionalSounds: parsedSounds,
      createdAt: json['created_at'],
      createdAtHuman: json['created_at_human'],
      updatedAt: json['updated_at'],
      updatedAtHuman: json['updated_at_human'],
      motivationalText: json['motivational_text'],
      personNum: json['person_num'],
      qrDescription: json['qr_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'native_name': nativeName,
      'flag_url': flagPath,
      'audio_url': audioPath,
      'is_local': isLocal,
      'remote_audio_filename': remoteAudioFileName,
      'motivational_text': motivationalText,
      'person_num': personNum,
      'qr_description': qrDescription,
      if (additionalSounds != null)
        'additional_sounds':
            additionalSounds!.map((sound) => sound.toJson()).toList(),
    };
  }
}
