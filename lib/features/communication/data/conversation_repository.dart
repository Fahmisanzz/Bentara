import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';

abstract class IConversationRepository {
  Future<String> saveConversation(String title, String userId, {String? contextStr});
  Future<void> saveMessage(String conversationId, ChatMessageModel message);
  Future<List<ChatMessageModel>> getConversationMessages(String conversationId);
}

class SupabaseConversationRepository implements IConversationRepository {
  final SupabaseClient _supabase;

  SupabaseConversationRepository(this._supabase);

  @override
  Future<String> saveConversation(String title, String userId, {String? contextStr}) async {
    try {
      final response = await _supabase.from('conversations').insert({
        'title': title,
        'user_id': userId,
        'context': contextStr ?? 'general',
        'started_at': DateTime.now().toIso8601String(),
      }).select('id').single();
      
      return response['id'] as String;
    } catch (e) {
      print('Failed to save conversation: $e');
      return 'local-convo-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  String _mapSourceType(SourceType type) {
    switch (type) {
      case SourceType.stt:
        return 'voice';
      case SourceType.tts:
      case SourceType.textInput:
        return 'text';
      case SourceType.sign:
        return 'sign';
    }
  }

  @override
  Future<void> saveMessage(String conversationId, ChatMessageModel message) async {
    try {
      if (conversationId.startsWith('local-convo-')) return; 

      final String senderTypeStr = message.sender.name == 'userTuli' ? 'tuli' : 'dengar';
      
      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_type': senderTypeStr,
        'input_type': _mapSourceType(message.sourceType),
        'original_text': message.originalText,
        'processed_text': message.contextualText,
        'output_text': message.text,
        'created_at': message.timestamp.toIso8601String(),
      });
    } catch (e) {
      print('Database Sync Failed for Message: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getConversationMessages(String conversationId) async {
    // Currently, history reading uses HistoryRepository. 
    // This is just a mock return if called from communication provider directly.
    return [];
  }
}
