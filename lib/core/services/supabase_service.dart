import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/env_keys.dart';

class SupabaseService {
  static Future<void> init() async {
    final url = dotenv.env[EnvKeys.supabaseUrl];
    final anonKey = dotenv.env[EnvKeys.supabaseAnonKey];

    if (url == null || anonKey == null || url.isEmpty || anonKey.isEmpty) {
      throw Exception('Supabase config not found in .env');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
