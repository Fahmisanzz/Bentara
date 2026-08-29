import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/context_preset.dart';
import '../../providers/communication_provider.dart';

class ContextSelectorBar extends ConsumerWidget {
  const ContextSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commState = ref.watch(communicationNotifierProvider);
    final notifier = ref.read(communicationNotifierProvider.notifier);

    return Container(
      height: 60,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: ContextPreset.values.length,
        itemBuilder: (context, index) {
          final preset = ContextPreset.values[index];
          final isSelected = commState.currentPreset == preset;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(preset.label),
              avatar: Icon(
                preset.icon,
                color: isSelected ? AppColors.surface : AppColors.primary,
                size: 18,
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.surface : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  notifier.setContextPreset(preset);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
