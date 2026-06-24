import 'dart:convert';
import 'dart:io';

import 'package:call_to_islam/models/language_model.dart';
import 'package:call_to_islam/services/supabase_language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class LanguageService {
  final SupabaseLanguageService _supabaseLanguage = SupabaseLanguageService();

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  static const String _cacheKey = 'cached_languages';

  List<Language> _allLanguages = [];
  List<Language> getCachedLanguages() => List.unmodifiable(_allLanguages);

  Future<bool> checkServerConnection() async {
    try {
      await _supabaseLanguage.getLanguages();
      _isOnline = true;
    } catch (_) {
      _isOnline = false;
    }
    return _isOnline;
  }

  Future<List<Language>> getAllLanguages() async {
    try {
      final languages = await _supabaseLanguage.getLanguages();
      _allLanguages = languages;
      _isOnline = true;
      await _saveToCache(languages);
      return languages;
    } catch (e) {
      _isOnline = false;
      final cached = await _loadFromCache();
      if (cached.isNotEmpty) {
        _allLanguages = cached;
        return cached;
      }
      rethrow;
    }
  }

  Future<void> _saveToCache(List<Language> languages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = languages.map((l) => l.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(json));
    } catch (_) {}
  }

  Future<List<Language>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return [];
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((e) => Language.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Language?> getLanguageById(String id) async {
    return _supabaseLanguage.getLanguageById(id);
  }

  Future<void> addLanguage({
    required String name,
    required String nativeName,
    required File flagFile,
    required File audioFile,
    String? qrLink,
    File? qrImageFile,
    String? motivationalText,
    String? whatsappNumber,
    List<Map<String, dynamic>>? subAudios,
    List<File>? bookFiles,
    List<String>? youtubeVideoUrls,
  }) async {
    await _supabaseLanguage.addLanguage(
      name: name,
      nativeName: nativeName,
      flagFile: flagFile,
      audioFile: audioFile,
      qrLink: qrLink,
      qrImageFile: qrImageFile,
      motivationalText: motivationalText,
      whatsappNumber: whatsappNumber,
      subAudios: subAudios,
      bookFiles: bookFiles,
      youtubeVideoUrls: youtubeVideoUrls,
    );
    await getAllLanguages();
  }

  Future<bool> isAudioCached(Language language) async {
    return language.isLocal || language.audioPath.isNotEmpty;
  }

  Future<String> getCachedFlagPath(Language language) async {
    return language.flagPath;
  }

  Future<String> getCachedAudioPath(Language language) async {
    return language.audioPath;
  }

  Future<String> getCachedAdditionalSoundPath(
    String url,
    String fileName,
  ) async {
    return url;
  }

  Future<void> updateLanguage({
    required String id,
    String? name,
    String? nativeName,
    File? flagFile,
    File? audioFile,
  }) async {
    await _supabaseLanguage.updateLanguage(
      id: id,
      name: name,
      nativeName: nativeName,
      flagFile: flagFile,
      audioFile: audioFile,
    );
    await getAllLanguages();
  }

  Future<void> deleteLanguage(String id) async {
    await _supabaseLanguage.deleteLanguage(id);
    await getAllLanguages();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    _allLanguages.clear();
  }
}
