import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class HistoryRepository {
  final SupabaseClient _supabase;
  
  HistoryRepository(this._supabase);

  Future<List<ConversationModel>> fetchConversations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('conversations')
          .select()
          .eq('user_id', user.id)
          .order('started_at', ascending: false);

      return (response as List).map((e) => ConversationModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _supabase.from('conversations').delete().eq('id', conversationId);
      return true;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }

  Future<List<MessageModel>> fetchMessagesForConversation(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }
}
