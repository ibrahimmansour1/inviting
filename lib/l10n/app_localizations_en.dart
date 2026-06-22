// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Call to Islam';

  @override
  String get languageSelection => 'Select a Language';

  @override
  String get searchLanguages => 'Search languages...';

  @override
  String get audioPlayer => 'Audio Player';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get share => 'Share';

  @override
  String get additionalSounds => 'Additional Sounds';

  @override
  String get books => 'Books';

  @override
  String get videos => 'Videos';

  @override
  String get settings => 'Settings';

  @override
  String get motivationalQuote => 'Motivational Message';

  @override
  String get connectShare => 'Connect & Share';

  @override
  String get whatsappContact => 'Contact via WhatsApp';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get chooseAnotherLanguage => 'Choose Another Language';

  @override
  String audioInfo(String language) {
    return 'This audio contains Islamic teachings in the $language language.';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get onlineMode => 'Online Mode';

  @override
  String shareAudio(String language, String nativeName) {
    return 'Listen to \"$language\" pronunciation ($nativeName)';
  }

  @override
  String shareAudioSubject(String language) {
    return 'Audio pronunciation - $language';
  }

  @override
  String failedToShareAudio(String error) {
    return 'Failed to share audio: $error';
  }

  @override
  String failedToOpenWhatsApp(String error) {
    return 'Failed to open WhatsApp: $error';
  }

  @override
  String get bookTitle => 'Book Title';

  @override
  String get readBook => 'Read Book';

  @override
  String get shareBook => 'Share Book';

  @override
  String get watchVideo => 'Watch Video';

  @override
  String get shareVideo => 'Share Video';

  @override
  String get noBooks => 'No books available';

  @override
  String get noVideos => 'No videos available';
}
