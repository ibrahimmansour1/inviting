import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try{
  await SupabaseConfig.initialize(
    url: 'https://ohjzdyjmsgcdsmqrprfd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9oanpkeWptc2djZHNtcXJwcmZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3OTY4ODgsImV4cCI6MjA5NzM3Mjg4OH0.S-x2c1HkdOvhIR68qGkOaPWX7VR4IASfiBKOmpZvGPA',
  );} catch (e){
        debugPrint('Supabase init error: $e');

  }
  
  runApp(const MyApp());
}
 