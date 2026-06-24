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
    await client.storage.from(bucket).upload(path, file);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadFlag(String languageName, File file) async {
    final ext = file.path.split('.').last;
    final path = '${languageName.replaceAll(' ', '_').toLowerCase()}_flag.$ext';
    return uploadFile(bucket: 'flags', path: path, file: file);
  }

  Future<String> uploadAudio(String languageName, File file) async {
    final ext = file.path.split('.').last;
    final path =
        '${languageName.replaceAll(' ', '_').toLowerCase()}_audio.$ext';
    return uploadFile(bucket: 'audios', path: path, file: file);
  }

  Future<String> uploadQrImage(String languageName, File file) async {
    final ext = file.path.split('.').last;
    final path = '${languageName.replaceAll(' ', '_').toLowerCase()}_qr.$ext';
    return uploadFile(bucket: 'qr_codes', path: path, file: file);
  }
}
