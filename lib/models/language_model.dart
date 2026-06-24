import 'additional_sound_model.dart';
import 'book_model.dart';
import 'video_model.dart';

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
  final List<Book>? books;
  final List<Video>? videos;
  final String? createdAt;
  final String? createdAtHuman;
  final String? updatedAt;
  final String? updatedAtHuman;
  final String? motivationalText;
  final int? personNum;
  final String? qrDescription;
  final String? qrImageUrl; // New field for QR code as image

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
    this.books,
    this.videos,
    this.createdAt,
    this.createdAtHuman,
    this.updatedAt,
    this.updatedAtHuman,
    this.motivationalText,
    this.personNum,
    this.qrDescription,
    this.qrImageUrl,
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
    List<Book>? books,
    List<Video>? videos,
    String? createdAt,
    String? createdAtHuman,
    String? updatedAt,
    String? updatedAtHuman,
    String? motivationalText,
    int? personNum,
    String? qrDescription,
    String? qrImageUrl,
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
      books: books ?? this.books,
      videos: videos ?? this.videos,
      createdAt: createdAt ?? this.createdAt,
      createdAtHuman: createdAtHuman ?? this.createdAtHuman,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedAtHuman: updatedAtHuman ?? this.updatedAtHuman,
      motivationalText: motivationalText ?? this.motivationalText,
      personNum: personNum ?? this.personNum,
      qrDescription: qrDescription ?? this.qrDescription,
      qrImageUrl: qrImageUrl ?? this.qrImageUrl,
    );
  }

  factory Language.fromSupabase(Map<String, dynamic> json) {
    final soundsList = json['additional_sounds'] as List?;
    final parsedSounds = soundsList != null
        ? soundsList
            .map((e) => AdditionalSound.fromSupabase(e as Map<String, dynamic>))
            .toList()
        : <AdditionalSound>[];

    final booksList = json['books'] as List?;
    final parsedBooks = booksList != null
        ? booksList
            .map((e) => Book.fromSupabase(e as Map<String, dynamic>))
            .toList()
        : <Book>[];

    final videosList = json['videos'] as List?;
    final parsedVideos = videosList != null
        ? videosList
            .map((e) => Video.fromSupabase(e as Map<String, dynamic>))
            .toList()
        : <Video>[];

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
      books: parsedBooks.isNotEmpty ? parsedBooks : null,
      videos: parsedVideos.isNotEmpty ? parsedVideos : null,
      createdAt: json['created_at'],
      createdAtHuman: json['created_at_human'],
      updatedAt: json['updated_at'],
      updatedAtHuman: json['updated_at_human'],
      motivationalText: json['motivational_text'],
      personNum: json['person_num'],
      qrDescription: json['qr_description'],
      qrImageUrl: json['qr_image_url'],
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
      'qr_image_url': qrImageUrl,
      if (additionalSounds != null)
        'additional_sounds':
            additionalSounds!.map((sound) => sound.toJson()).toList(),
      if (books != null) 'books': books!.map((book) => book.toJson()).toList(),
      if (videos != null)
        'videos': videos!.map((video) => video.toJson()).toList(),
    };
  }
}
