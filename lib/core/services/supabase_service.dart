import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/env_keys.dart';

class SupabaseService {
  static const String defaultUrl = 'https://cewfiihogysmcgigcbxl.supabase.co';
  static const String defaultAnonKey = 'sb_publishable_0C-_Ayid8aUqWCxbrato8w_uMwabadW';

  static Future<void> init() async {
    final url = dotenv.env[EnvKeys.supabaseUrl] ?? defaultUrl;
    final anonKey = dotenv.env[EnvKeys.supabaseAnonKey] ?? defaultAnonKey;

    await Supabase.initialize(
      url: url.isNotEmpty ? url : defaultUrl,
      anonKey: anonKey.isNotEmpty ? anonKey : defaultAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
