import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
    // Pesan Pengguna -> Align Kanan. 
    // Dalam konteks ini diasumsikan user adalah Teman Tuli (app owner).
    final isCurrentUser = widget.message.sender == SenderType.userTuli;
    final hasContext = widget.message.isContextApplied && widget.message.originalText != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: Radius.circular(isCurrentUser ? 16.0 : 4.0),
                  bottomRight: Radius.circular(isCurrentUser ? 4.0 : 16.0),
                ),
                border: isCurrentUser
                    ? null
                    : Border.all(color: Colors.grey.shade200, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SENDER & CONTEXT BADGE ---
                  if (hasContext)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCurrentUser 
                              ? Colors.white.withValues(alpha: 0.2) 
                              : AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.message.appliedContext!.icon,
                              size: 12,
                              color: isCurrentUser ? Colors.white : AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI: ${widget.message.appliedContext!.label}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isCurrentUser ? Colors.white : AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- MAIN TEXT ---
                  Text(
                    _showOriginal ? widget.message.originalText! : widget.message.text,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      height: 1.3,
                      fontStyle: _showOriginal ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),

                  // --- TOGGLE ORIGINAL TEXT ---
                  if (hasContext) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showOriginal = !_showOriginal;
                        });
                      },
                      child: Text(
                        _showOriginal ? 'Sembunyikan Teks Asli' : 'Lihat Teks Asli',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCurrentUser ? Colors.white70 : AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
