import 'dart:io';

import 'package:call_to_islam/core/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseService {
  SupabaseService._();
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;

  SupabaseClient get client => SupabaseConfig.client;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      // Try to upload the file
      await client.storage.from(bucket).upload(path, file);
    } catch (e) {
      // If file already exists (duplicate), use upsert to replace it
      if (e.toString().contains('Duplicate') ||
          e.toString().contains('409') ||
          e.toString().contains('already exists')) {
        // Use upsert option to replace existing file
        await client.storage.from(bucket).upload(
              path,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        rethrow;
      }
    }
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Sanitizes a language name to be safe for use as a Supabase Storage key.
  /// Removes any characters that are not alphanumeric, underscores, or hyphens.
  String _sanitizeStorageKey(String name) {
    return name
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_\-]'), '');
  }

  Future<String> uploadFlag(String languageName, File file) async {
    final ext = file.path.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${_sanitizeStorageKey(languageName)}_flag_$timestamp.$ext';
    return uploadFile(bucket: 'flags', path: path, file: file);
  }

  Future<String> uploadAudio(String languageName, File file) async {
    final ext = file.path.split('.').last;
    final path = '${_sanitizeStorageKey(languageName)}_audio.$ext';
    return uploadFile(bucket: 'audios', path: path, file: file);
  }

  Future<String> uploadQrImage(String languageName, File file) async {
    final ext = file.path.split('.').last;
    final path = '${_sanitizeStorageKey(languageName)}_qr.$ext';
    return uploadFile(bucket: 'qr_codes', path: path, file: file);
  }

  Future<String> uploadAdditionalSound(String languageName, File file) async {
    final ext = file.path.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${_sanitizeStorageKey(languageName)}_sub_$timestamp.$ext';
    return uploadFile(bucket: 'audios', path: path, file: file);
  }

  Future<String> uploadBook(String languageName, File file) async {
    final ext = file.path.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${_sanitizeStorageKey(languageName)}_book_$timestamp.$ext';
    return uploadFile(bucket: 'books', path: path, file: file);
  }
}
