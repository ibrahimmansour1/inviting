class Language {
  final String name;
  final String nativeName;
  final String flagPath;
  final String audioPath;
  final bool isLocal; // True if audio is bundled with app, false if remote
  final String? remoteAudioFileName; // Filename for remote audio

  Language({
    required this.name,
    required this.nativeName,
    required this.flagPath,
    required this.audioPath,
    this.isLocal = false,
    this.remoteAudioFileName,
  });

  // Get the filename for remote audio
  String get audioFileName {
    if (remoteAudioFileName != null) {
      return remoteAudioFileName!;
    }
    // Extract filename from audioPath
    return audioPath.split('/').last;
  }
}

final List<Language> languages = [
  // LOCAL LANGUAGES (First 5 - bundled with app)
  // 1
  Language(
      name: 'English',
      nativeName: 'إنجليزي',
      flagPath: 'assets/flags/usa.png',
      audioPath: 'assets/audio/english.m4a',
      isLocal: true),
  // 2
  Language(
      name: 'Español',
      nativeName: 'إسباني',
      flagPath: 'assets/flags/spain.png',
      audioPath: 'assets/audio/spanish.m4a',
      isLocal: true),
  // 3
  Language(
      name: 'Français',
      nativeName: 'فرنسي',
      flagPath: 'assets/flags/france.png',
      audioPath: 'assets/audio/french.m4a',
      isLocal: true),
  // 4
  Language(
      name: 'Deutsch',
      nativeName: 'الماني',
      flagPath: 'assets/flags/germany.png',
      audioPath: 'assets/audio/german.m4a',
      isLocal: true),
  // 5
  Language(
      name: 'Italiano',
      nativeName: 'إيطالي',
      flagPath: 'assets/flags/italy.png',
      audioPath: 'assets/audio/italian.m4a',
      isLocal: true),

  // REMOTE LANGUAGES (Downloaded on demand)
  // 6
  Language(
      name: 'Bahasa Indonesia',
      nativeName: 'إندونيسي',
      flagPath: 'assets/flags/indonesia.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'indonesian.m4a'),
  // 7
  Language(
      name: 'Kiswahili',
      nativeName: 'سواحيلي',
      flagPath: 'assets/flags/kenya.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'swahili.m4a'),
  // 8
  Language(
      name: 'Khmer',
      nativeName: 'خميري (كمبودي)',
      flagPath: 'assets/flags/cambodia.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'khmer.m4a'),
  // 9
  Language(
      name: 'Telugu',
      nativeName: 'تلغو',
      flagPath: 'assets/flags/india.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'telugu.m4a'),
  // 10
  Language(
      name: 'Georgian',
      nativeName: 'جورجي',
      flagPath: 'assets/flags/georgia.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'georgian.m4a'),
  // 11
  Language(
      name: 'Nepali',
      nativeName: 'نيبالي',
      flagPath: 'assets/flags/nepal.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'nepali.m4a'),
  // 12
  Language(
      name: 'Burmese',
      nativeName: 'برماوي (بورمي)',
      flagPath: 'assets/flags/myanmar.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'burmese.m4a'),
  // 13
  Language(
      name: 'Nederlands',
      nativeName: 'هولندي',
      flagPath: 'assets/flags/netherlands.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'dutch.m4a'),
  // 14
  Language(
      name: 'Oʻzbekcha',
      nativeName: 'أوزبكي',
      flagPath: 'assets/flags/uzbekistan.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'uzbek.m4a'),
  // 15
  Language(
      name: 'Tamil',
      nativeName: 'تاميلي',
      flagPath: 'assets/flags/tamil.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'tamil.m4a'),
  // 16
  Language(
      name: 'Malayalam',
      nativeName: 'مليباري (ماليالام)',
      flagPath: 'assets/flags/kerala.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'malayalam.m4a'),
  // 17
  Language(
      name: 'Hindi',
      nativeName: 'هندي',
      flagPath: 'assets/flags/india.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'hindi.m4a'),
  // 18
  Language(
      name: 'Kirundi / Kinyarwanda',
      nativeName: 'كيروندي / روندي',
      flagPath: 'assets/flags/rwanda.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'kinyarwanda.m4a'),
  // 19
  Language(
      name: 'Sinhala',
      nativeName: 'سنهالي',
      flagPath: 'assets/flags/srilanka.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'sinhala.m4a'),
  // 20
  Language(
      name: 'Bangla',
      nativeName: 'بنغالي',
      flagPath: 'assets/flags/bangladesh.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'bengali.m4a'),
  // 21
  Language(
      name: 'Mandinka',
      nativeName: 'مندنكي',
      flagPath: 'assets/flags/gambia.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'mandinka.m4a'),
  // 22
  Language(
      name: 'Malagasy',
      nativeName: 'ملغاشي',
      flagPath: 'assets/flags/madagascar.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'malagasy.m4a'),
  // 23
  Language(
      name: 'Thai',
      nativeName: 'تايلاندي',
      flagPath: 'assets/flags/thailand.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'thai.m4a'),
  // 24
  Language(
      name: 'Hausa',
      nativeName: 'هوساوي',
      flagPath: 'assets/flags/nigeria.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'hausa.m4a'),
  // 25
  Language(
      name: 'Lao',
      nativeName: 'لاوي',
      flagPath: 'assets/flags/laos.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'lao.m4a'),
  // 26
  Language(
      name: 'Shqip',
      nativeName: 'ألباني',
      flagPath: 'assets/flags/albania.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'albanian.m4a'),
  // 27
  Language(
      name: 'Dagbani',
      nativeName: 'دغباني (داغومبا)',
      flagPath: 'assets/flags/ghana.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'dagbani.m4a'),
  // 28
  Language(
      name: 'Yorùbá',
      nativeName: 'يوربا',
      flagPath: 'assets/flags/nigeria.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'yoruba.m4a'),
  // 29
  Language(
      name: 'Bahasa Melayu',
      nativeName: 'ملايوي',
      flagPath: 'assets/flags/malaysia.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'malay.m4a'),
  // 30
  Language(
      name: 'Português',
      nativeName: 'برتغالي',
      flagPath: 'assets/flags/brazil.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'portuguese.m4a'),
  // 31
  Language(
      name: 'Gujarati',
      nativeName: 'غجراتي',
      flagPath: 'assets/flags/india.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'gujarati.m4a'),
  // 32
  Language(
      name: 'Suomi',
      nativeName: 'فنلندي',
      flagPath: 'assets/flags/finland.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'finnish.m4a'),
  // 33
  Language(
      name: 'Fulfulde',
      nativeName: 'فلاتي (فولفولدي)',
      flagPath: 'assets/flags/nigeria.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'fulfulde.m4a'),
  // 34
  Language(
      name: 'Русский',
      nativeName: 'روسي',
      flagPath: 'assets/flags/russia.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'russian.m4a'),
  // 35
  Language(
      name: 'Marathi',
      nativeName: 'مراثي',
      flagPath: 'assets/flags/india.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'marathi.m4a'),
  // 36
  Language(
      name: 'Lingála',
      nativeName: 'لنغالا',
      flagPath: 'assets/flags/congo.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'lingala.m4a'),
  // 37
  Language(
      name: 'Amharic',
      nativeName: 'أمهرية',
      flagPath: 'assets/flags/ethiopia.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'amharic.m4a'),
  // 38
  Language(
      name: 'Urdu',
      nativeName: 'أردو',
      flagPath: 'assets/flags/pakistan.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'urdu.m4a'),
  // 39
  Language(
      name: 'Chinese',
      nativeName: 'صيني',
      flagPath: 'assets/flags/china.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'chinese.m4a'),
  // 40
  Language(
      name: 'Vietnamese',
      nativeName: 'فيتنامي',
      flagPath: 'assets/flags/vietnam.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'vietnamese.m4a'),
  // 41
  Language(
      name: 'Korean',
      nativeName: 'كوري',
      flagPath: 'assets/flags/south_korea.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'korean.m4a'),
  // 42
  Language(
      name: 'Japanese',
      nativeName: 'ياباني',
      flagPath: 'assets/flags/japan.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'japanese.m4a'),
  // 43
  Language(
      name: 'Filipino',
      nativeName: 'فلبيني',
      flagPath: 'assets/flags/philippines.png',
      audioPath: 'remote',
      isLocal: false,
      remoteAudioFileName: 'filipino.m4a'),
];
