import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/chat_message_model.dart';
import '../../models/context_preset.dart';

class ContextMessageBubble extends StatefulWidget {
  final ChatMessageModel message;

  const ContextMessageBubble({super.key, required this.message});

  @override
  State<ContextMessageBubble> createState() => _ContextMessageBubbleState();
}

class _ContextMessageBubbleState extends State<ContextMessageBubble> {
  bool _showOriginal = false;

  @override
  Widget build(BuildContext context) {
    final isTuli = widget.message.sender == SenderType.userTuli;
    final hasContext = widget.message.isContextApplied && widget.message.originalText != null;

    return Align(
      alignment: isTuli ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isTuli ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isTuli ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender Label & Context Badge
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isTuli ? 'Teman Tuli' : 'Teman Dengar',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isTuli ? Colors.white70 : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasContext) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(widget.message.appliedContext!.icon, size: 12, color: isTuli ? Colors.white : AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'AI: ${widget.message.appliedContext!.label}',
                          style: TextStyle(fontSize: 10, color: isTuli ? Colors.white : AppColors.secondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 6),
            
            // Main Text (Contextual or Original)
            Text(
              _showOriginal ? widget.message.originalText! : widget.message.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isTuli ? Colors.white : AppColors.textPrimary,
                fontStyle: _showOriginal ? FontStyle.italic : FontStyle.normal,
              ),
            ),

            // Toggle Button for Original Text
            if (hasContext) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _showOriginal = !_showOriginal;
                  });
                },
                child: Text(
                  _showOriginal ? 'Sembunyikan Teks Asli' : 'Lihat Teks Asli',
                  style: TextStyle(
                    fontSize: 12,
                    color: isTuli ? Colors.white70 : AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
