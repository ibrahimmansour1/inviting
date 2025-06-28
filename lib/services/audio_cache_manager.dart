import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// Custom exception for network-related errors
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class AudioCacheManager {
  static final AudioCacheManager _instance = AudioCacheManager._internal();
  factory AudioCacheManager() => _instance;
  AudioCacheManager._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'https://ksamade.com/apk-audio/';

  // Download progress callbacks
  final Map<String, Function(double)> _downloadProgressCallbacks = {};
  final Map<String, bool> _downloadingFiles = {};
  final Connectivity _connectivity = Connectivity();

  // Get the cache directory for audio files
  Future<Directory> get _cacheDir async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/audio_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  // Get local file path for a given audio filename
  Future<String> _getLocalFilePath(String audioFileName) async {
    final cacheDir = await _cacheDir;
    return '${cacheDir.path}/$audioFileName';
  }

  // Check if audio file is cached locally
  Future<bool> isAudioCached(String audioFileName) async {
    final filePath = await _getLocalFilePath(audioFileName);
    return File(filePath).exists();
  }

  // Get cached audio file path if it exists
  Future<String?> getCachedAudioPath(String audioFileName) async {
    if (await isAudioCached(audioFileName)) {
      return await _getLocalFilePath(audioFileName);
    }
    return null;
  }

  // Download audio file and cache it with retry mechanism
  Future<String> downloadAndCacheAudio(
    String audioFileName, {
    Function(double)? onProgress,
  }) async {
    return await _downloadWithRetry(audioFileName, onProgress: onProgress);
  }

  // Download with retry and exponential backoff
  Future<String> _downloadWithRetry(
    String audioFileName, {
    Function(double)? onProgress,
    int retryCount = 0,
  }) async {
    // Check if already downloading
    if (_downloadingFiles[audioFileName] == true) {
      // Wait for existing download to complete
      while (_downloadingFiles[audioFileName] == true) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      // Return cached path after download completes
      return await _getLocalFilePath(audioFileName);
    }

    // Check if already cached
    if (await isAudioCached(audioFileName)) {
      return await _getLocalFilePath(audioFileName);
    }

    // Check internet connectivity first
    if (!await hasInternetConnection()) {
      throw NetworkException(
          'No internet connection. Please check your network and try again.');
    }

    // Start downloading
    _downloadingFiles[audioFileName] = true;
    if (onProgress != null) {
      _downloadProgressCallbacks[audioFileName] = onProgress;
    }

    try {
      final url = '$_baseUrl$audioFileName';
      final filePath = await _getLocalFilePath(audioFileName);

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _downloadProgressCallbacks[audioFileName]?.call(progress);
            onProgress?.call(progress);
          }
        },
      );

      _downloadingFiles[audioFileName] = false;
      _downloadProgressCallbacks.remove(audioFileName);

      return filePath;
    } on DioException catch (e) {
      _downloadingFiles[audioFileName] = false;
      _downloadProgressCallbacks.remove(audioFileName);

      // Implement retry logic for certain types of errors
      if (_shouldRetry(e) && retryCount < 3) {
        // Calculate delay with exponential backoff
        final delay = Duration(seconds: (retryCount + 1) * 2);
        await Future.delayed(delay);

        return await _downloadWithRetry(audioFileName,
            onProgress: onProgress, retryCount: retryCount + 1);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
            'Connection timeout. Please check your internet connection and try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            'Cannot connect to server. Please check your internet connection.');
      } else if (e.response?.statusCode == 404) {
        throw NetworkException('Audio file not found on server.');
      } else {
        throw NetworkException(
            'Download failed: ${e.message ?? "Unknown network error"}');
      }
    } catch (e) {
      _downloadingFiles[audioFileName] = false;
      _downloadProgressCallbacks.remove(audioFileName);
      throw NetworkException('Failed to download audio: $e');
    }
  }

  // Check if currently downloading
  bool isDownloading(String audioFileName) {
    return _downloadingFiles[audioFileName] == true;
  }

  // Get download progress for a file
  void setDownloadProgressCallback(
      String audioFileName, Function(double) callback) {
    _downloadProgressCallbacks[audioFileName] = callback;
  }

  // Clear all cached audio files
  Future<void> clearCache() async {
    final cacheDir = await _cacheDir;
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  // Get cache size in bytes
  Future<int> getCacheSize() async {
    final cacheDir = await _cacheDir;
    if (!await cacheDir.exists()) return 0;

    int totalSize = 0;
    await for (final file in cacheDir.list(recursive: true)) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  }

  // Format cache size to human readable string
  String formatCacheSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  // Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Check if connected to WiFi or mobile data
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // For now, if we have WiFi or mobile data, assume we have internet
      // The actual server check will happen during download
      if (connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile)) {
        return true;
      }

      return false;
    } catch (e) {
      // If connectivity check fails, assume no connection
      return false;
    }
  }

  // Check if a Dio exception should trigger a retry
  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.response?.statusCode != null &&
            e.response!.statusCode! >= 500 &&
            e.response!.statusCode! < 600);
  }
}
