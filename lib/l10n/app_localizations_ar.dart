// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دعوة إلى الإسلام';

  @override
  String get languageSelection => 'اختر لغة';

  @override
  String get searchLanguages => 'ابحث عن اللغات...';

  @override
  String get audioPlayer => 'مشغل الصوت';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف';

  @override
  String get share => 'مشاركة';

  @override
  String get additionalSounds => 'ملفات صوتية إضافية';

  @override
  String get books => 'كتب';

  @override
  String get videos => 'فيديوهات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get motivationalQuote => 'رسالة تحفيزية';

  @override
  String get connectShare => 'تواصل وشارك';

  @override
  String get whatsappContact => 'تواصل عبر واتساب';

  @override
  String get scanQRCode => 'امسح رمز QR';

  @override
  String get chooseAnotherLanguage => 'اختر لغة أخرى';

  @override
  String audioInfo(String language) {
    return 'يحتوي هذا الصوت على تعاليم إسلامية باللغة $language.';
  }

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get offlineMode => 'وضع غير متصل';

  @override
  String get onlineMode => 'وضع متصل';

  @override
  String shareAudio(String language, String nativeName) {
    return 'استمع إلى نطق \"$language\" ($nativeName)';
  }

  @override
  String shareAudioSubject(String language) {
    return 'نطق صوتي - $language';
  }

  @override
  String failedToShareAudio(String error) {
    return 'فشلت مشاركة الصوت: $error';
  }

  @override
  String failedToOpenWhatsApp(String error) {
    return 'فشل فتح واتساب: $error';
  }

  @override
  String get bookTitle => 'عنوان الكتاب';

  @override
  String get readBook => 'قراءة الكتاب';

  @override
  String get shareBook => 'مشاركة الكتاب';

  @override
  String get watchVideo => 'شاهد الفيديو';

  @override
  String get shareVideo => 'شارك الفيديو';

  @override
  String get noBooks => 'لا توجد كتب متاحة';

  @override
  String get noVideos => 'لا توجد فيديوهات متاحة';
}
