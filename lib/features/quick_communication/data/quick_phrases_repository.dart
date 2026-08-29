import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quick_phrase_model.dart';

class QuickPhrasesRepository {
  final SupabaseClient _supabase;
  QuickPhrasesRepository(this._supabase);

  Future<List<QuickPhraseModel>> fetchPhrases() async {
    try {
      final user = _supabase.auth.currentUser;
      
      // Fetch system default phrases + user custom phrases
      final response = await _supabase
          .from('quick_phrases')
          .select()
          .or('user_id.is.null,user_id.eq.${user?.id}');

      return (response as List).map((e) => QuickPhraseModel.fromJson(e)).toList();
    } catch (e) {
      print('Failed to fetch quick phrases: $e');
      return [];
    }
  }
}
