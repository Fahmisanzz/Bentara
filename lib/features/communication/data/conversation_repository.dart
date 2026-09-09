import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/chat_message_model.dart';

abstract class IConversationRepository {
  Future<String> saveConversation(String title, String userId, {String? contextStr, String? id});
  Future<void> saveMessage(String conversationId, ChatMessageModel message);
  Future<void> updateMessage(String conversationId, String messageId, String newText, {DateTime? updatedAt});
  Future<List<ChatMessageModel>> getConversationMessages(String conversationId);
}

class SupabaseConversationRepository implements IConversationRepository {
  final SupabaseClient _supabase;
  final ILocalStorageService _localStorage;

  SupabaseConversationRepository(this._supabase, this._localStorage);

  @override
  Future<String> saveConversation(String title, String userId, {String? contextStr, String? id}) async {
    final convoId = id ?? const Uuid().v4();
    final nowStr = DateTime.now().toIso8601String();

    // 1. Simpan ke Cache Lokal Hive (Per User)
    try {
      final key = 'conversations_$userId';
      final cachedStr = _localStorage.getString(key);
      List<dynamic> list = [];
      if (cachedStr != null) {
        try {
          list = jsonDecode(cachedStr) as List<dynamic>;
        } catch (_) {}
      }

      // Hapus jika sudah ada id yang sama untuk di-update
      list.removeWhere((item) => item['id'] == convoId);

      list.insert(0, {
        'id': convoId,
        'title': title,
        'user_id': userId,
        'context': contextStr ?? 'general',
        'started_at': nowStr,
      });

      await _localStorage.saveString(key, jsonEncode(list));
    } catch (_) {}

    // 2. Sinkronkan ke Supabase jika online
    try {
      final response = await _supabase.from('conversations').upsert({
        'id': convoId,
        'title': title,
        'user_id': userId,
        'context': contextStr ?? 'general',
        'started_at': nowStr,
      }).select('id').maybeSingle();

      if (response != null && response['id'] != null) {
        return response['id'] as String;
      }
    } catch (_) {
      // Supabase offline / RLS fallback
    }

    return convoId;
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
    final senderTypeStr = message.sender.name == 'userTuli' ? 'tuli' : 'dengar';
    final inputTypeStr = _mapSourceType(message.sourceType);
    final nowStr = message.timestamp.toIso8601String();

    // 1. Simpan ke Cache Lokal Hive (Per Conversation)
    try {
      final key = 'messages_$conversationId';
      final cachedStr = _localStorage.getString(key);
      List<dynamic> list = [];
      if (cachedStr != null) {
        try {
          list = jsonDecode(cachedStr) as List<dynamic>;
        } catch (_) {}
      }

      list.add({
        'id': message.id,
        'conversation_id': conversationId,
        'sender_type': senderTypeStr,
        'input_type': inputTypeStr,
        'original_text': message.originalText,
        'processed_text': message.contextualText,
        'output_text': message.text,
        'created_at': nowStr,
        'is_edited': message.isEdited,
        'updated_at': message.updatedAt?.toIso8601String(),
      });

      await _localStorage.saveString(key, jsonEncode(list));
    } catch (_) {}

    // 2. Sinkronkan ke Supabase jika online
    try {
      await _supabase.from('messages').insert({
        'id': message.id,
        'conversation_id': conversationId,
        'sender_type': senderTypeStr,
        'input_type': inputTypeStr,
        'original_text': message.originalText,
        'processed_text': message.contextualText,
        'output_text': message.text,
        'created_at': nowStr,
        'is_edited': message.isEdited,
        'updated_at': message.updatedAt?.toIso8601String(),
      });
    } catch (_) {
      // Supabase offline / RLS fallback
    }
  }

  @override
  Future<void> updateMessage(String conversationId, String messageId, String newText, {DateTime? updatedAt}) async {
    final nowStr = (updatedAt ?? DateTime.now()).toIso8601String();

    // 1. Simpan ke Cache Lokal Hive (Per Conversation)
    try {
      final key = 'messages_$conversationId';
      final cachedStr = _localStorage.getString(key);
      if (cachedStr != null) {
        final list = jsonDecode(cachedStr) as List<dynamic>;
        for (int i = 0; i < list.length; i++) {
          if (list[i]['id'] == messageId) {
            list[i]['output_text'] = newText;
            list[i]['is_edited'] = true;
            list[i]['updated_at'] = nowStr;
            break;
          }
        }
        await _localStorage.saveString(key, jsonEncode(list));
      }
    } catch (_) {}

    // 2. Sinkronkan ke Supabase jika online
    try {
      await _supabase.from('messages').update({
        'output_text': newText,
        'is_edited': true,
        'updated_at': nowStr,
      }).eq('id', messageId);
    } catch (_) {
      // Supabase offline / RLS fallback
    }
  }

  @override
  Future<List<ChatMessageModel>> getConversationMessages(String conversationId) async {
    try {
      final key = 'messages_$conversationId';
      final cachedStr = _localStorage.getString(key);
      if (cachedStr != null) {
        final list = jsonDecode(cachedStr) as List<dynamic>;
        return list.map((m) {
          return ChatMessageModel(
            id: m['id'] ?? const Uuid().v4(),
            text: m['output_text'] ?? '',
            sender: m['sender_type'] == 'tuli' ? SenderType.userTuli : SenderType.userDengar,
            timestamp: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
            sourceType: m['input_type'] == 'voice' 
                ? SourceType.stt 
                : (m['input_type'] == 'sign' ? SourceType.sign : SourceType.textInput),
            contextualText: m['processed_text'],
            originalText: m['original_text'],
            isEdited: m['is_edited'] ?? false,
            updatedAt: m['updated_at'] != null ? DateTime.parse(m['updated_at']) : null,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
