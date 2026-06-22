import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseConfig {
  SupabaseConfig._();
  static final SupabaseConfig _instance = SupabaseConfig._();
  factory SupabaseConfig() => _instance;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
