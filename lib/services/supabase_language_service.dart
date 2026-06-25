import 'dart:io';

import 'package:call_to_islam/models/language_model.dart';
import 'package:call_to_islam/services/supabase_service.dart';

final class SupabaseLanguageService {
  final SupabaseService _supabase = SupabaseService();

  Future<List<Language>> getLanguages() async {
    final data = await _supabase.client
        .from('languages')
        .select('*, additional_sounds(*), books(*), videos(*)');

    return data
        .map((e) => Language.fromSupabase(Map<String, dynamic>.from(e)))
        .toList();
  }

  Stream<List<Language>> streamLanguages() {
    return _supabase.client.from('languages').stream(primaryKey: ['id']).map(
        (data) => data
            .map((e) => Language.fromSupabase(Map<String, dynamic>.from(e)))
            .toList());
  }

  Future<Language?> getLanguageById(String id) async {
    try {
      final data = await _supabase.client
          .from('languages')
          .select('*, additional_sounds(*), books(*), videos(*)')
          .eq('id', id)
          .single();
      return Language.fromSupabase(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
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
    List<Map<String, dynamic>>? subAudios, // {file: File, title: String}
    List<File>? bookFiles,
    List<String>? youtubeVideoUrls,
  }) async {
    // Upload required files
    final flagUrl = await _supabase.uploadFlag(name, flagFile);
    final audioUrl = await _supabase.uploadAudio(name, audioFile);

    String? qrImageUrl;
    if (qrImageFile != null) {
      qrImageUrl = await _supabase.uploadQrImage(name, qrImageFile);
    }

    // Insert language record
    final languageData = await _supabase.client
        .from('languages')
        .insert({
          'name': name,
          'native_name': nativeName,
          'flag_url': flagUrl,
          'audio_url': audioUrl,
          if (qrLink != null && qrLink.isNotEmpty) 'qr_description': qrLink,
          if (qrImageUrl != null) 'qr_image_url': qrImageUrl,
          if (motivationalText != null && motivationalText.isNotEmpty)
            'motivational_text': motivationalText,
          if (whatsappNumber != null && whatsappNumber.isNotEmpty)
            'person_num': whatsappNumber,
        })
        .select()
        .single();

    final languageId = languageData['id'].toString();

    // Upload and insert sub-audios
    if (subAudios != null && subAudios.isNotEmpty) {
      for (var audio in subAudios) {
        final file = audio['file'] as File;
        final title = audio['title'] as String;
        final audioUrl = await _supabase.uploadAdditionalSound(name, file);
        await _supabase.client.from('additional_sounds').insert({
          'language_id': languageId,
          'name': title,
          'file_url': audioUrl,
        });
      }
    }

    // Upload and insert books
    if (bookFiles != null && bookFiles.isNotEmpty) {
      for (var file in bookFiles) {
        final bookUrl = await _supabase.uploadBook(name, file);
        final fileName = file.path.split('/').last;
        await _supabase.client.from('books').insert({
          'language_id': languageId,
          'title': fileName,
          'file_url': bookUrl,
        });
      }
    }

    // Insert YouTube videos
    if (youtubeVideoUrls != null && youtubeVideoUrls.isNotEmpty) {
      for (var url in youtubeVideoUrls) {
        // Extract video ID from URL for use as title fallback
        final uri = Uri.tryParse(url);
        final videoId = uri?.queryParameters['v'] ??
            uri?.pathSegments.lastOrNull ??
            'YouTube Video';
        await _supabase.client.from('videos').insert({
          'language_id': languageId,
          'video_url': url,
          'title': videoId,
        });
      }
    }
  }

  Future<void> updateLanguage({
    required String id,
    String? name,
    String? nativeName,
    File? flagFile,
    File? audioFile,
    String? qrLink,
    File? qrImageFile,
  }) async {
    final updates = <String, dynamic>{};

    if (name != null) updates['name'] = name;
    if (nativeName != null) updates['native_name'] = nativeName;
    if (flagFile != null) {
      updates['flag_url'] = await _supabase.uploadFlag(name ?? id, flagFile);
    }
    if (audioFile != null) {
      updates['audio_url'] = await _supabase.uploadAudio(name ?? id, audioFile);
    }
    if (qrLink != null) {
      updates['qr_description'] = qrLink;
    }
    if (qrImageFile != null) {
      updates['qr_image_url'] =
          await _supabase.uploadQrImage(name ?? id, qrImageFile);
    }

    if (updates.isNotEmpty) {
      await _supabase.client.from('languages').update(updates).eq('id', id);
    }
  }

  Future<void> deleteLanguage(String id) async {
    await _supabase.client.from('languages').delete().eq('id', id);
  }
}
