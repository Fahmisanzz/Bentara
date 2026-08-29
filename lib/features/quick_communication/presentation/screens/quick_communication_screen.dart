import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/quick_phrase_model.dart';
import '../../providers/quick_communication_provider.dart';

class QuickCommunicationScreen extends ConsumerWidget {
  const QuickCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickCommNotifierProvider);
    final notifier = ref.read(quickCommNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunikasi Cepat'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: notifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari kalimat cepat...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),
          
          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _CategoryChip(
                  label: 'Semua',
                  isSelected: state.selectedCategory == null,
                  onTap: () => notifier.setCategory(null),
                ),
                ...state.availableCategories.map((cat) => _CategoryChip(
                  label: cat.toUpperCase(),
                  isSelected: state.selectedCategory == cat,
                  onTap: () => notifier.setCategory(cat),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Phrase List
          Expanded(
            child: state.phrases.when(
              data: (phrases) {
                if (phrases.isEmpty) {
                  return const Center(child: Text('Belum ada phrase yang tersedia di database.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: state.filteredPhrases.length,
                  itemBuilder: (context, index) {
                    final phrase = state.filteredPhrases[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  phrase.category.toUpperCase(),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                IconButton(
                                  icon: Icon(phrase.isFavorite ? Icons.star : Icons.star_border, color: Colors.amber),
                                  onPressed: () => notifier.toggleFavorite(phrase.id),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(phrase.phrase, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: phrase.phrase));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teks disalin ke clipboard')));
                                    },
                                    icon: const Icon(Icons.copy, size: 18),
                                    label: const Text('Salin'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: () => notifier.speakPhrase(phrase.phrase),
                                    icon: const Icon(Icons.volume_up),
                                    label: const Text('Ucapkan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            )
          )
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
      ),
    );
  }
}
