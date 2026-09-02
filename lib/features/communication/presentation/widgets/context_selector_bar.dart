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
      height: 56,
      color: Colors.white,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, overscroll: false),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
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
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 18,
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
      ),
    );
  }
}
