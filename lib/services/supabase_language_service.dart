import 'dart:io';

import 'package:call_to_islam/models/language_model.dart';
import 'package:call_to_islam/services/supabase_service.dart';

final class SupabaseLanguageService {
  final SupabaseService _supabase = SupabaseService();

  Future<List<Language>> getLanguages() async {
    final data = await _supabase.client
        .from('languages')
        .select('*, additional_sounds(*)');

    return data
        .map((e) => Language.fromSupabase(Map<String, dynamic>.from(e)))
        .toList();
  }

  Stream<List<Language>> streamLanguages() {
    return _supabase.client
        .from('languages')
        .stream(primaryKey: ['id'])
        .map((data) => data
            .map((e) => Language.fromSupabase(Map<String, dynamic>.from(e)))
            .toList());
  }

  Future<Language?> getLanguageById(String id) async {
    try {
      final data = await _supabase.client
          .from('languages')
          .select('*, additional_sounds(*)')
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
  }) async {
    final flagUrl = await _supabase.uploadFlag(name, flagFile);
    final audioUrl = await _supabase.uploadAudio(name, audioFile);

    await _supabase.client.from('languages').insert({
      'name': name,
      'native_name': nativeName,
      'flag_url': flagUrl,
      'audio_url': audioUrl,
    });
  }

  Future<void> updateLanguage({
    required String id,
    String? name,
    String? nativeName,
    File? flagFile,
    File? audioFile,
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

    if (updates.isNotEmpty) {
      await _supabase.client.from('languages').update(updates).eq('id', id);
    }
  }

  Future<void> deleteLanguage(String id) async {
    await _supabase.client.from('languages').delete().eq('id', id);
  }
}
