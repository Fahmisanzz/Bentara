import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/history_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Percakapan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: historyAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada riwayat percakapan.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Hapus Riwayat?'),
                        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Hapus'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  ref.read(historyListProvider.notifier).deleteConversation(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Percakapan dihapus'), backgroundColor: AppColors.secondary),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withOpacity(0.2),
                      child: const Icon(Icons.chat_bubble_outline, color: AppColors.secondary),
                    ),
                    title: Text(item.title ?? 'Percakapan Tanpa Judul', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.context ?? 'General', maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text('${item.startedAt.day}/${item.startedAt.month}', style: const TextStyle(color: Colors.grey)),
                    onTap: () {
                      context.pushNamed(
                        RouteNames.communication,
                        extra: {'conversationId': item.id},
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
