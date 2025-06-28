import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/language_model.dart';
import 'api_service.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final ApiService _apiService = ApiService();
  List<Language> _allLanguages = [];
  bool _isOnline = false;
  static const String _cacheKey = 'cached_languages';

  // Get all languages from backend only, with local caching
  Future<List<Language>> getAllLanguages() async {
    await _checkConnectivity();

    if (!_isOnline) {
      // Try to load from cache when offline
      return await _loadFromCache();
    }

    try {
      _allLanguages = await _apiService.getLanguages();
      print('Loaded ${_allLanguages.length} languages from backend');

      // Cache the languages for offline use
      await _saveToCache(_allLanguages);

      return _allLanguages;
    } catch (e) {
      print('Error loading languages: $e');

      // Try to load from cache if backend fails
      final cachedLanguages = await _loadFromCache();
      if (cachedLanguages.isNotEmpty) {
        print('Loaded ${cachedLanguages.length} languages from cache');
        _allLanguages = cachedLanguages;
        return cachedLanguages;
      }

      throw Exception(
          'Failed to load languages from backend and no cached data available: $e');
    }
  }

  // Save languages to local cache
  Future<void> _saveToCache(List<Language> languages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languagesJson = languages.map((lang) => lang.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(languagesJson));
      await prefs.setInt(
          '${_cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
      print('Cached ${languages.length} languages locally');
    } catch (e) {
      print('Failed to cache languages: $e');
    }
  }

  // Load languages from local cache
  Future<List<Language>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        final List<dynamic> languagesJson = jsonDecode(cachedData);
        final languages =
            languagesJson.map((json) => Language.fromJson(json)).toList();
        return languages;
      }
    } catch (e) {
      print('Failed to load cached languages: $e');
    }

    return [];
  }

  // Clear cached languages
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove('${_cacheKey}_timestamp');
      print('Language cache cleared');
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  // Check if cached languages are available
  Future<bool> hasCachedLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      return cachedData != null && cachedData.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get cache timestamp
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('${_cacheKey}_timestamp');
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      return null;
    }
  }

  // Get all languages from cache (for offline access after first load)
  List<Language> getCachedLanguages() {
    return _allLanguages;
  }

  // Add a new language to the backend
  Future<Language> addLanguage({
    required String name,
    required String nativeName,
    required File flagFile,
    required File audioFile,
  }) async {
    await _checkConnectivity();

    if (!_isOnline) {
      throw Exception('Internet connection required to add new languages');
    }

    try {
      final newLanguage = await _apiService.addLanguage(
        name: name,
        nativeName: nativeName,
        flagFile: flagFile,
        audioFile: audioFile,
      );

      // Refresh the languages list
      await getAllLanguages();

      return newLanguage;
    } catch (e) {
      throw Exception('Failed to add language: $e');
    }
  }

  // Update an existing language
  Future<Language> updateLanguage({
    required String id,
    String? name,
    String? nativeName,
    File? flagFile,
    File? audioFile,
  }) async {
    await _checkConnectivity();

    if (!_isOnline) {
      throw Exception('Internet connection required to update languages');
    }

    try {
      final updatedLanguage = await _apiService.updateLanguage(
        id: id,
        name: name,
        nativeName: nativeName,
        flagFile: flagFile,
        audioFile: audioFile,
      );

      // Refresh the languages list
      await getAllLanguages();

      return updatedLanguage;
    } catch (e) {
      throw Exception('Failed to update language: $e');
    }
  }

  // Delete a language
  Future<void> deleteLanguage(String id) async {
    await _checkConnectivity();

    if (!_isOnline) {
      throw Exception('Internet connection required to delete languages');
    }

    try {
      await _apiService.deleteLanguage(id);

      // Refresh the languages list
      await getAllLanguages();
    } catch (e) {
      throw Exception('Failed to delete language: $e');
    }
  }

  // Get a cached audio file path for all languages
  Future<String> getCachedAudioPath(Language language) async {
    try {
      // For all languages, download and cache the audio file from backend
      final baseUrl =
          'http://ip-185-177-73-30-121929.vps.hosted-by-mvps.net'; // Use your server URL
      final remoteUrl = language.audioPath.startsWith('http')
          ? language.audioPath
          : '$baseUrl${language.audioPath}';

      return await _apiService.downloadAndCacheFile(
        remoteUrl,
        language.audioFileName,
      );
    } catch (e) {
      throw Exception('Failed to cache audio file: $e');
    }
  }

  // Get a cached flag image path for all languages
  Future<String> getCachedFlagPath(Language language) async {
    try {
      // For all languages, download and cache the flag image from backend
      final baseUrl =
          'http://ip-185-177-73-30-121929.vps.hosted-by-mvps.net'; // Use your server URL
      final remoteUrl = language.flagPath.startsWith('http')
          ? language.flagPath
          : '$baseUrl${language.flagPath}';
      final filename = language.flagPath.split('/').last;

      return await _apiService.downloadAndCacheFile(remoteUrl, filename);
    } catch (e) {
      throw Exception('Failed to cache flag image: $e');
    }
  }

  // Check if server is available
  Future<bool> checkServerConnection() async {
    await _checkConnectivity();

    if (!_isOnline) {
      return false;
    }

    return await _apiService.checkServerHealth();
  }

  // Check internet connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    _isOnline = !connectivityResults.contains(ConnectivityResult.none);
  }

  // Get connectivity status
  bool get isOnline => _isOnline;

  // Get cached languages list
  List<Language> get cachedLanguages => _allLanguages;

  // Get language details by ID (includes additional sounds)
  Future<Language> getLanguageById(String id) async {
    await _checkConnectivity();

    if (!_isOnline) {
      throw Exception('Internet connection required to fetch language details');
    }

    try {
      return await _apiService.getLanguageById(id);
    } catch (e) {
      throw Exception('Failed to load language details: $e');
    }
  }

  // Get cached additional sound file path
  Future<String> getCachedAdditionalSoundPath(
      String soundUrl, String filename) async {
    try {
      final baseUrl = 'http://ip-185-177-73-30-121929.vps.hosted-by-mvps.net';
      final remoteUrl =
          soundUrl.startsWith('http') ? soundUrl : '$baseUrl$soundUrl';

      return await _apiService.downloadAndCacheFile(remoteUrl, filename);
    } catch (e) {
      throw Exception('Failed to cache additional sound file: $e');
    }
  }
}
