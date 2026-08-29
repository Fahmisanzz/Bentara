import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quick_phrase_model.dart';
import '../data/quick_phrases_repository.dart';
import '../../communication/providers/communication_provider.dart';

final quickPhrasesRepoProvider = Provider((ref) => QuickPhrasesRepository(Supabase.instance.client));

class QuickCommunicationState {
  final AsyncValue<List<QuickPhraseModel>> phrases;
  final String? selectedCategory;
  final String searchQuery;

  QuickCommunicationState({
    this.phrases = const AsyncValue.loading(),
    this.selectedCategory,
    this.searchQuery = '',
  });

  List<QuickPhraseModel> get filteredPhrases {
    final list = phrases.valueOrNull ?? [];
    return list.where((p) {
      final matchesCategory = selectedCategory == null || p.category.toLowerCase() == selectedCategory?.toLowerCase();
      final matchesSearch = p.phrase.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get availableCategories {
    final list = phrases.valueOrNull ?? [];
    final cats = list.map((e) => e.category).toSet().toList();
    cats.sort();
    return cats;
  }

  QuickCommunicationState copyWith({
    AsyncValue<List<QuickPhraseModel>>? phrases,
    String? selectedCategory,
    String? searchQuery,
    bool clearCategory = false,
  }) {
    return QuickCommunicationState(
      phrases: phrases ?? this.phrases,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class QuickCommunicationNotifier extends StateNotifier<QuickCommunicationState> {
  final Ref _ref;
  
  QuickCommunicationNotifier(this._ref) : super(QuickCommunicationState()) {
    _loadPhrases();
  }

  Future<void> _loadPhrases() async {
    state = state.copyWith(phrases: const AsyncValue.loading());
    try {
      final repo = _ref.read(quickPhrasesRepoProvider);
      final phrases = await repo.fetchPhrases();
      state = state.copyWith(phrases: AsyncValue.data(phrases));
    } catch (e, st) {
      state = state.copyWith(phrases: AsyncValue.error(e, st));
    }
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category, clearCategory: category == null);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFavorite(String id) {
    final list = state.phrases.valueOrNull;
    if (list == null) return;

    final newPhrases = list.map((p) {
      if (p.id == id) return p.copyWith(isFavorite: !p.isFavorite);
      return p;
    }).toList();
    state = state.copyWith(phrases: AsyncValue.data(newPhrases));
  }

  Future<void> speakPhrase(String sentence) async {
    final ttsService = _ref.read(ttsServiceProvider);
    await ttsService.speak(sentence);
  }
}

final quickCommNotifierProvider = StateNotifierProvider<QuickCommunicationNotifier, QuickCommunicationState>((ref) {
  return QuickCommunicationNotifier(ref);
});
