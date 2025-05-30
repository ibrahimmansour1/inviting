class Language {
  final String name;
  final String nativeName;
  final String flagPath;
  final String audioPath;

  Language({
    required this.name,
    required this.nativeName,
    required this.flagPath,
    required this.audioPath,
  });
}

final List<Language> languages = [
  // 1
  Language(
      name: 'Bahasa Indonesia',
      nativeName: 'إندونيسي',
      flagPath: 'assets/flags/indonesia.png',
      audioPath: 'assets/audio/indonesian.m4a'),
  // 2
  Language(
      name: 'Kiswahili',
      nativeName: 'سواحيلي',
      flagPath: 'assets/flags/kenya.png',
      audioPath: 'assets/audio/swahili.m4a'),
  // 3
  Language(
      name: 'Khmer',
      nativeName: 'خميري (كمبودي)',
      flagPath: 'assets/flags/cambodia.png',
      audioPath: 'assets/audio/khmer.m4a'),
  // 4
  Language(
      name: 'Telugu',
      nativeName: 'تلغو',
      flagPath: 'assets/flags/india.png',
      audioPath: 'assets/audio/telugu.m4a'),
  // 5
  Language(
      name: 'Georgian',
      nativeName: 'جورجي',
      flagPath: 'assets/flags/georgia.png',
      audioPath: 'assets/audio/georgian.m4a'),
  // 6
  Language(
      name: 'Nepali',
      nativeName: 'نيبالي',
      flagPath: 'assets/flags/nepal.png',
      audioPath: 'assets/audio/nepali.m4a'),
  // 7
  Language(
      name: 'Burmese',
      nativeName: 'برماوي (بورمي)',
      flagPath: 'assets/flags/myanmar.png',
      audioPath: 'assets/audio/burmese.m4a'),
  // 8
  Language(
      name: 'Nederlands',
      nativeName: 'هولندي',
      flagPath: 'assets/flags/netherlands.png',
      audioPath: 'assets/audio/dutch.m4a'),
  // 9
  Language(
      name: 'Oʻzbekcha',
      nativeName: 'أوزبكي',
      flagPath: 'assets/flags/uzbekistan.png',
      audioPath: 'assets/audio/uzbek.m4a'),
  // 10
  Language(
      name: 'Tamil',
      nativeName: 'تاميلي',
      flagPath: 'assets/flags/tamil.png',
      audioPath: 'assets/audio/tamil.m4a'),
  // 11
  Language(
      name: 'English',
      nativeName: 'إنجليزي',
      flagPath: 'assets/flags/usa.png',
      audioPath: 'assets/audio/english.m4a'),
  // 12
  Language(
      name: 'Malayalam',
      nativeName: 'مليباري (ماليالام)',
      flagPath: 'assets/flags/kerala.png',
      audioPath: 'assets/audio/malayalam.m4a'),
  // 13
  Language(
      name: 'Hindi',
      nativeName: 'هندي',
      flagPath: 'assets/flags/india.png',
      audioPath: 'assets/audio/hindi.m4a'),
  // 14
  Language(
      name: 'Español',
      nativeName: 'إسباني',
      flagPath: 'assets/flags/spain.png',
      audioPath: 'assets/audio/spanish.m4a'),
  // 15
  Language(
      name: 'Kirundi / Kinyarwanda',
      nativeName: 'كيروندي / روندي',
      flagPath: 'assets/flags/rwanda.png',
      audioPath: 'assets/audio/kinyarwanda.m4a'),
  // 16
  Language(
      name: 'Sinhala',
      nativeName: 'سنهالي',
      flagPath: 'assets/flags/srilanka.png',
      audioPath: 'assets/audio/sinhala.m4a'),
  // 17
  Language(
      name: 'Bangla',
      nativeName: 'بنغالي',
      flagPath: 'assets/flags/bangladesh.png',
      audioPath: 'assets/audio/bengali.m4a'),
  // 18
  Language(
      name: 'Mandinka',
      nativeName: 'مندنكي',
      flagPath: 'assets/flags/gambia.png',
      audioPath: 'assets/audio/mandinka.m4a'),
  // 19
  Language(
      name: 'Malagasy',
      nativeName: 'ملغاشي',
      flagPath: 'assets/flags/madagascar.png',
      audioPath: 'assets/audio/malagasy.m4a'),
  // 20
  Language(
      name: 'Deutsch',
      nativeName: 'الماني',
      flagPath: 'assets/flags/germany.png',
      audioPath: 'assets/audio/german.m4a'),
  // 21
  Language(
      name: 'Thai',
      nativeName: 'تايلاندي',
      flagPath: 'assets/flags/thailand.png',
      audioPath: 'assets/audio/thai.m4a'),
  // 22
  Language(
      name: 'Hausa',
      nativeName: 'هوساوي',
      flagPath: 'assets/flags/nigeria.png',
      audioPath: 'assets/audio/hausa.m4a'),
  // 23
  Language(
      name: 'Français',
      nativeName: 'فرنسي',
      flagPath: 'assets/flags/france.png',
      audioPath: 'assets/audio/french.m4a'),
  // 24
  Language(
      name: 'Lao',
      nativeName: 'لاوي',
      flagPath: 'assets/flags/laos.png',
      audioPath: 'assets/audio/lao.m4a'),
  // 25
  Language(
      name: 'Shqip',
      nativeName: 'ألباني',
      flagPath: 'assets/flags/albania.png',
      audioPath: 'assets/audio/albanian.m4a'),
  // 26
  Language(
      name: 'Dagbani',
      nativeName: 'دغباني (داغومبا)',
      flagPath: 'assets/flags/ghana.png',
      audioPath: 'assets/audio/dagbani.m4a'),
  // 27
  Language(
      name: 'Yorùbá',
      nativeName: 'يوربا',
      flagPath: 'assets/flags/nigeria.png',
      audioPath: 'assets/audio/yoruba.m4a'),
  // 28
  Language(
      name: 'Bahasa Melayu',
      nativeName: 'ملايوي',
      flagPath: 'assets/flags/malaysia.png',
      audioPath: 'assets/audio/malay.m4a'),
  // 29
  Language(
      name: 'Português',
      nativeName: 'برتغالي',
      flagPath: 'assets/flags/brazil.png',
      audioPath: 'assets/audio/portuguese.m4a'),
  // 30
  Language(
      name: 'Gujarati',
      nativeName: 'غجراتي',
      flagPath: 'assets/flags/india.png',
      audioPath: 'assets/audio/gujarati.m4a'),
  // 31
  Language(
      name: 'Suomi',
      nativeName: 'فنلندي',
      flagPath: 'assets/flags/finland.png',
      audioPath: 'assets/audio/finnish.m4a'),
  // 32
  Language(
      name: 'Fulfulde',
      nativeName: 'فلاتي (فولفولدي)',
      flagPath: 'assets/flags/nigeria.png',
      audioPath: 'assets/audio/fulfulde.m4a'),
  // 33
  Language(
      name: 'Русский',
      nativeName: 'روسي',
      flagPath: 'assets/flags/russia.png',
      audioPath: 'assets/audio/russian.m4a'),
  // 34
  Language(
      name: 'Marathi',
      nativeName: 'مراثي',
      flagPath: 'assets/flags/india.png',
      audioPath: 'assets/audio/marathi.m4a'),
  // 35
  Language(
      name: 'Lingála',
      nativeName: 'لنغالا',
      flagPath: 'assets/flags/congo.png',
      audioPath: 'assets/audio/lingala.m4a'),
  // 36
  Language(
      name: 'Amharic',
      nativeName: 'أمهرية',
      flagPath: 'assets/flags/ethiopia.png',
      audioPath: 'assets/audio/amharic.m4a'),
  // 37
  Language(
      name: 'Urdu',
      nativeName: 'أردو',
      flagPath: 'assets/flags/pakistan.png',
      audioPath: 'assets/audio/urdu.m4a'),
  // 38
  Language(
      name: 'Italiano',
      nativeName: 'إيطالي',
      flagPath: 'assets/flags/italy.png',
      audioPath: 'assets/audio/italian.m4a'),
  // 39
  Language(
      name: 'Chinese',
      nativeName: 'صيني',
      flagPath: 'assets/flags/china.png',
      audioPath: 'assets/audio/chinese.m4a'),
  // 40
  Language(
      name: 'Vietnamese',
      nativeName: 'فيتنامي',
      flagPath: 'assets/flags/vietnam.png',
      audioPath: 'assets/audio/vietnamese.m4a'),
  // 41
  Language(
      name: 'Korean',
      nativeName: 'كوري',
      flagPath: 'assets/flags/south_korea.png',
      audioPath: 'assets/audio/korean.m4a'),
  // 42
  Language(
      name: 'Japanese',
      nativeName: 'ياباني',
      flagPath: 'assets/flags/japan.png',
      audioPath: 'assets/audio/japanese.m4a'),
  // 43
  Language(
      name: 'Filipino',
      nativeName: 'فلبيني',
      flagPath: 'assets/flags/philippines.png',
      audioPath: 'assets/audio/filipino.m4a'),
];
