import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/message_model.dart';

class ReplyPreviewWidget extends StatelessWidget {
  final MessageModel replyMessage;
  final VoidCallback onCancel;

  const ReplyPreviewWidget({
    super.key,
    required this.replyMessage,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  replyMessage.replyToSenderName ?? 'Message',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyMessage.displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
