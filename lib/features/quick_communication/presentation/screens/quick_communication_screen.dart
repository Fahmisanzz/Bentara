import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/quick_communication_provider.dart';
import '../../models/quick_phrase_model.dart';

// ================================================================
// BENTARA — HALAMAN KOMUNIKASI CEPAT
// Blue × White Design System — No Glassmorphism
// ================================================================
class QuickCommunicationScreen extends ConsumerStatefulWidget {
  const QuickCommunicationScreen({super.key});

  @override
  ConsumerState<QuickCommunicationScreen> createState() =>
      _QuickCommunicationScreenState();
}

class _QuickCommunicationScreenState
    extends ConsumerState<QuickCommunicationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quickCommNotifierProvider);
    final notifier = ref.read(quickCommNotifierProvider.notifier);

    // Keep status bar dark icons on blue header
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.accentPurple, // LAYER 1
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            // ─────────────────────────────────────────────
            // HEADER — Purple
            // ─────────────────────────────────────────────
            _Header(),

            // ─────────────────────────────────────────────
            // LAYER 2: SOLID WHITE PANEL
            // ─────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
                ),
                child: Column(
                  children: [
                    // SEARCH BAR
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _SearchBar(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (query) {
                          notifier.setSearchQuery(query);
                          setState(() {}); // refresh clear button
                        },
                        onClear: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                          setState(() {});
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CATEGORY FILTER
                    SizedBox(
                      height: 44,
                      child: state.phrases.when(
                        data: (phrases) => _CategoryFilter(
                          categories: state.availableCategories,
                          selectedCategory: state.selectedCategory,
                          onCategorySelected: notifier.setCategory,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PHRASE LIST
                    Expanded(
                      child: state.phrases.when(
                        data: (phrases) {
                          final filtered = state.filteredPhrases;
                          if (filtered.isEmpty) {
                            return _EmptyState(
                              hasSearch: state.searchQuery.isNotEmpty,
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.paddingOf(context).bottom),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(
                                bottom: index == filtered.length - 1 ? 0 : 14,
                              ),
                              child: _PhraseCard(
                                phrase: filtered[index],
                                onFavoriteToggle: () =>
                                    notifier.toggleFavorite(filtered[index].id),
                                onCopy: () {
                                  Clipboard.setData(
                                    ClipboardData(text: filtered[index].phrase),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Kalimat berhasil disalin'),
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                onSpeak: () =>
                                    notifier.speakPhrase(filtered[index].phrase),
                              ),
                            ),
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentPurple,
                          ),
                        ),
                        error: (err, _) => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: AppColors.error),
                              SizedBox(height: 12),
                              Text(
                                'Gagal memuat kalimat cepat',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Periksa koneksi internet Anda',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom safe area for Android navigation bar
                    const SafeArea(top: false, child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// HEADER WIDGET
// ================================================================
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.accentPurple,
      padding: EdgeInsets.only(
        top: topPadding + 6,
        bottom: 14,
        left: 4,
        right: 16,
      ),
      child: Row(
        children: [
          // Back button with 44px touch target
          Semantics(
            label: 'Kembali',
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Komunikasi Cepat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SEARCH BAR WIDGET
// ================================================================
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE1E7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Cari kalimat cepat...',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: controller.text.isNotEmpty
              ? Semantics(
                  label: 'Hapus pencarian',
                  child: GestureDetector(
                    onTap: onClear,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 44),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ================================================================
// CATEGORY FILTER
// ================================================================
class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const _CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  String _translateCategory(String raw) {
    switch (raw.toLowerCase()) {
      case 'general':
      case 'umum':
        return 'Umum';
      case 'medical':
      case 'medis':
        return 'Medis';
      case 'public':
      case 'publik':
        return 'Publik';
      default:
        // Capitalize first letter
        return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // "Semua" chip
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _CategoryChip(
            label: 'Semua',
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
        ),
        // Dynamic category chips
        ...categories.map((cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                label: _translateCategory(cat),
                isSelected: selectedCategory?.toLowerCase() ==
                    cat.toLowerCase(),
                onTap: () => onCategorySelected(cat),
              ),
            )),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPurple : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.accentPurple
                : const Color(0xFFCDD5E0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// PHRASE CARD WIDGET
// ================================================================
class _PhraseCard extends StatelessWidget {
  final QuickPhraseModel phrase;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onCopy;
  final VoidCallback onSpeak;

  const _PhraseCard({
    required this.phrase,
    required this.onFavoriteToggle,
    required this.onCopy,
    required this.onSpeak,
  });

  String _translateCategory(String raw) {
    switch (raw.toLowerCase()) {
      case 'general':
      case 'umum':
        return 'UMUM';
      case 'medical':
      case 'medis':
        return 'MEDIS';
      case 'public':
      case 'publik':
        return 'PUBLIK';
      default:
        return raw.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEFF4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Category Label + Favorite button ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category accent pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _translateCategory(phrase.category),
                    style: const TextStyle(
                      color: AppColors.accentPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const Spacer(),
                // Favorite button
                Semantics(
                  label: phrase.isFavorite
                      ? 'Hapus dari favorit'
                      : 'Tambahkan ke favorit',
                  child: SizedBox(
                    width: 44,
                    height: 36,
                    child: IconButton(
                      icon: Icon(
                        phrase.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 22,
                        color: phrase.isFavorite
                            ? AppColors.accentPurple
                            : const Color(0xFFB0B8C8),
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: onFavoriteToggle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Row 2: Phrase text ──
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                phrase.phrase,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Row 3: Action buttons ──
            Row(
              children: [
                // Salin — Secondary (outlined, blue)
                Semantics(
                  label: 'Salin kalimat',
                  child: _ActionButton(
                    icon: Icons.content_copy_rounded,
                    label: 'Salin',
                    isOutlined: true,
                    onTap: onCopy,
                  ),
                ),
                const SizedBox(width: 10),
                // Ucapkan — Primary (filled, green)
                Expanded(
                  child: Semantics(
                    label: 'Ucapkan kalimat',
                    child: _ActionButton(
                      icon: Icons.volume_up_rounded,
                      label: 'Ucapkan',
                      isOutlined: false,
                      onTap: onSpeak,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ACTION BUTTON (Salin / Ucapkan)
// ================================================================
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOutlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isOutlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      // Salin button — secondary outlined
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.accentPurple,
          side: const BorderSide(color: AppColors.accentPurple, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      // Ucapkan button — primary filled (purple)
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}

// ================================================================
// EMPTY STATE
// ================================================================
class _EmptyState extends StatelessWidget {
  final bool hasSearch;

  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.chat_bubble_outline_rounded,
              size: 56,
              color: const Color(0xFFB0B8C8),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'Tidak ada kalimat yang ditemukan'
                  : 'Belum ada kalimat tersedia',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Coba kata kunci yang berbeda'
                  : 'Kalimat cepat akan muncul di sini',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
