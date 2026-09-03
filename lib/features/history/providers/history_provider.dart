import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/conversation_model.dart';
import '../data/history_repository.dart';

final historyRepoProvider = Provider((ref) => HistoryRepository(
  Supabase.instance.client,
  ref.read(localStorageProvider),
));

class HistoryListNotifier extends StateNotifier<AsyncValue<List<ConversationModel>>> {
  final HistoryRepository _repo;

  HistoryListNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  void reset() {
    state = const AsyncValue.data([]);
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.fetchConversations();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> deleteConversation(String id) async {
    final success = await _repo.deleteConversation(id);
    if (success) {
      // Remove from state immediately for snappy UI
      if (state is AsyncData) {
        final currentList = state.value!;
        state = AsyncValue.data(currentList.where((c) => c.id != id).toList());
      }
    }
    return success;
  }
}

final historyListProvider = StateNotifierProvider<HistoryListNotifier, AsyncValue<List<ConversationModel>>>((ref) {
  return HistoryListNotifier(ref.read(historyRepoProvider));
});
