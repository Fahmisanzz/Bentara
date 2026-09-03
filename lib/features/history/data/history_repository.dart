import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class HistoryRepository {
  final SupabaseClient _supabase;
  final ILocalStorageService _localStorage;
  
  HistoryRepository(this._supabase, this._localStorage);

  Future<List<ConversationModel>> fetchConversations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final key = 'conversations_${user.id}';
    List<ConversationModel> localList = [];

    // 1. Ambil dari cache lokal Hive terlebih dahulu agar instan
    try {
      final cachedStr = _localStorage.getString(key);
      if (cachedStr != null) {
        final raw = jsonDecode(cachedStr) as List<dynamic>;
        localList = raw.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // 2. Ambil dari Supabase dan gabungkan
    try {
      final response = await _supabase
          .from('conversations')
          .select()
          .eq('user_id', user.id)
          .order('started_at', ascending: false);

      final remoteList = (response as List).map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
      
      // Gabungkan tanpa duplikat ID
      final Map<String, ConversationModel> mergedMap = {};
      for (var c in localList) {
        mergedMap[c.id] = c;
      }
      for (var c in remoteList) {
        mergedMap[c.id] = c; // remote takes precedence
      }

      final mergedList = mergedMap.values.toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      // Simpan pembaruan ke cache lokal
      try {
        await _localStorage.saveString(key, jsonEncode(mergedList.map((c) => c.toJson()).toList()));
      } catch (_) {}

      return mergedList;
    } catch (e) {
      debugPrint('Error fetching remote conversations: $e');
      return localList;
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final key = 'conversations_${user.id}';
      try {
        final cachedStr = _localStorage.getString(key);
        if (cachedStr != null) {
          final raw = jsonDecode(cachedStr) as List<dynamic>;
          raw.removeWhere((item) => item['id'] == conversationId);
          await _localStorage.saveString(key, jsonEncode(raw));
        }
        await _localStorage.remove('messages_$conversationId');
      } catch (_) {}
    }

    try {
      await _supabase.from('conversations').delete().eq('id', conversationId);
      return true;
    } catch (e) {
      debugPrint('Error deleting conversation remotely: $e');
      return true; // Tetap true karena lokal sudah berhasil dihapus
    }
  }

  Future<List<MessageModel>> fetchMessagesForConversation(String conversationId) async {
    final key = 'messages_$conversationId';
    List<MessageModel> localMessages = [];

    // 1. Ambil dari cache lokal Hive
    try {
      final cachedStr = _localStorage.getString(key);
      if (cachedStr != null) {
        final raw = jsonDecode(cachedStr) as List<dynamic>;
        localMessages = raw.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // 2. Coba sinkronisasi dari Supabase
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final remoteMessages = (response as List).map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
      
      final Map<String, MessageModel> mergedMap = {};
      for (var m in localMessages) {
        mergedMap[m.id] = m;
      }
      for (var m in remoteMessages) {
        mergedMap[m.id] = m;
      }

      final mergedList = mergedMap.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      try {
        await _localStorage.saveString(key, jsonEncode(mergedList.map((m) => m.toJson()).toList()));
      } catch (_) {}

      return mergedList;
    } catch (e) {
      debugPrint('Error fetching messages remotely: $e');
      return localMessages;
    }
  }
}
