import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Call to Islam'**
  String get appTitle;

  /// Title for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select a Language'**
  String get languageSelection;

  /// Hint text for language search field
  ///
  /// In en, this message translates to:
  /// **'Search languages...'**
  String get searchLanguages;

  /// Title for audio player screen
  ///
  /// In en, this message translates to:
  /// **'Audio Player'**
  String get audioPlayer;

  /// Play button label
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Pause button label
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Additional sounds section title
  ///
  /// In en, this message translates to:
  /// **'Additional Sounds'**
  String get additionalSounds;

  /// Books section title
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// Videos section title
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Motivational quote section title
  ///
  /// In en, this message translates to:
  /// **'Motivational Message'**
  String get motivationalQuote;

  /// Connect and share section title
  ///
  /// In en, this message translates to:
  /// **'Connect & Share'**
  String get connectShare;

  /// WhatsApp contact button label
  ///
  /// In en, this message translates to:
  /// **'Contact via WhatsApp'**
  String get whatsappContact;

  /// QR code section title
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// Button to go back to language selection
  ///
  /// In en, this message translates to:
  /// **'Choose Another Language'**
  String get chooseAnotherLanguage;

  /// Information about the audio content
  ///
  /// In en, this message translates to:
  /// **'This audio contains Islamic teachings in the {language} language.'**
  String audioInfo(String language);

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No internet error message
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// Offline mode indicator
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// Online mode indicator
  ///
  /// In en, this message translates to:
  /// **'Online Mode'**
  String get onlineMode;

  /// Share audio text
  ///
  /// In en, this message translates to:
  /// **'Listen to \"{language}\" pronunciation ({nativeName})'**
  String shareAudio(String language, String nativeName);

  /// Share audio subject
  ///
  /// In en, this message translates to:
  /// **'Audio pronunciation - {language}'**
  String shareAudioSubject(String language);

  /// Error message when sharing audio fails
  ///
  /// In en, this message translates to:
  /// **'Failed to share audio: {error}'**
  String failedToShareAudio(String error);

  /// Error message when opening WhatsApp fails
  ///
  /// In en, this message translates to:
  /// **'Failed to open WhatsApp: {error}'**
  String failedToOpenWhatsApp(String error);

  /// Book title label
  ///
  /// In en, this message translates to:
  /// **'Book Title'**
  String get bookTitle;

  /// Read book button
  ///
  /// In en, this message translates to:
  /// **'Read Book'**
  String get readBook;

  /// Share book button
  ///
  /// In en, this message translates to:
  /// **'Share Book'**
  String get shareBook;

  /// Watch video button
  ///
  /// In en, this message translates to:
  /// **'Watch Video'**
  String get watchVideo;

  /// Share video button
  ///
  /// In en, this message translates to:
  /// **'Share Video'**
  String get shareVideo;

  /// No books message
  ///
  /// In en, this message translates to:
  /// **'No books available'**
  String get noBooks;

  /// No videos message
  ///
  /// In en, this message translates to:
  /// **'No videos available'**
  String get noVideos;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
