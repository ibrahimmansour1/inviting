import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/language_model.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl =
      'http://ip-185-177-73-30-121929.vps.hosted-by-mvps.net/api'; // Updated to use your API

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 30),
    ));

    // Add request/response interceptors for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));
  }
  Future<List<Language>> getLanguages() async {
    try {
      final response = await _dio.get('/languages');

      if (response.statusCode == 200 && response.data['status']) {
        final List<dynamic> languagesData = response.data['data'];
        return languagesData.map((json) => Language.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load languages: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${_handleDioError(e)}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  Future<Language> addLanguage({
    required String name,
    required String nativeName,
    required File flagFile,
    required File audioFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'english_name': name,
        'native_name': nativeName,
        'flag': await MultipartFile.fromFile(
          flagFile.path,
          filename: flagFile.path.split('/').last,
        ),
        'sound': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/languages',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 201 && response.data['status']) {
        // Updated status field
        return Language.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to add language: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${_handleDioError(e)}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
    try {
      Map<String, dynamic> formFields = {};

      if (name != null) formFields['english_name'] = name;
      if (nativeName != null) formFields['native_name'] = nativeName;

      if (flagFile != null) {
        formFields['flag'] = await MultipartFile.fromFile(
          flagFile.path,
          filename: flagFile.path.split('/').last,
        );
      }

      if (audioFile != null) {
        formFields['sound'] = await MultipartFile.fromFile(
          // Updated field name
          audioFile.path,
          filename: audioFile.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(formFields);

      final response = await _dio.put(
        '/languages/$id',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['status']) {
        // Updated status field
        return Language.fromJson(response.data['data']);
      } else {
        throw Exception(
            'Failed to update language: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${_handleDioError(e)}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Delete a language
  Future<void> deleteLanguage(String id) async {
    try {
      final response = await _dio.delete('/languages/$id');

      if (response.statusCode == 200 && response.data['status']) {
        // Updated status field
        return;
      } else {
        throw Exception(
            'Failed to delete language: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${_handleDioError(e)}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Download and cache a remote file
  Future<String> downloadAndCacheFile(String remoteUrl, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/cached_files/$filename';

      // Create directory if it doesn't exist
      final file = File(filePath);
      await file.parent.create(recursive: true);

      // Download the file
      await _dio.download(
        remoteUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
                'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      return filePath;
    } on DioException catch (e) {
      throw Exception('Download error: ${_handleDioError(e)}');
    } catch (e) {
      throw Exception('File caching error: $e');
    }
  }

  // Check server health
  Future<bool> checkServerHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200 &&
          response.data['status'] == true; // Updated status field
    } catch (e) {
      return false;
    }
  }

  // Get language details by ID (includes additional sounds)
  Future<Language> getLanguageById(String id) async {
    try {
      final response = await _dio.get('/languages/$id');

      if (response.statusCode == 200 && response.data['status']) {
        return Language.fromJson(response.data['data']);
      } else {
        throw Exception(
            'Failed to load language details: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${_handleDioError(e)}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper method to handle Dio errors
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      default:
        return 'Unknown error occurred';
    }
  }
}
