import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/message_model.dart';
import 'voice_player_widget.dart';

class ChatBubbleWidget extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final String currentUserId;
  final VoidCallback onLongPress;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUserId,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeletedFor(currentUserId)) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? AppColors.primary
        : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant);

    final textColor = isMe
        ? Colors.white
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply preview header
              if (message.replyToMessageId != null)
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: Colors.amber, width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.replyToSenderName ?? 'Reply',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message.replyToText ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: textColor),
                      ),
                    ],
                  ),
                ),

              // Content based on message type
              _buildContent(context, textColor),

              // Bottom status line (Timestamp & Read Receipt Checkmarks)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 8, bottom: 6, top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (message.isEdited)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          'edited',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    Text(
                      DateFormatter.formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(),
                    ],
                  ],
                ),
              ),

              // Emoji Reactions List
              if (message.reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
                  child: Wrap(
                    spacing: 4,
                    children: message.reactions.entries.map((e) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          e.value,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    if (message.isDeletedForEveryone) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, size: 16, color: textColor.withAlpha(150)),
            const SizedBox(width: 6),
            Text(
              'This message was deleted',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: textColor.withAlpha(180),
              ),
            ),
          ],
        ),
      );
    }

    switch (message.type) {
      case AppConstants.messageTypeImage:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: message.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            if (message.text != null && message.text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  message.text!,
                  style: TextStyle(fontSize: 15, color: textColor),
                ),
              ),
          ],
        );

      case AppConstants.messageTypeAudio:
        return VoicePlayerWidget(
          audioUrl: message.audioUrl ?? '',
          durationInSeconds: message.audioDuration,
          isMe: isMe,
        );

      case AppConstants.messageTypeText:
      default:
        return Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 4),
          child: Text(
            message.text ?? '',
            style: TextStyle(fontSize: 15, color: textColor),
          ),
        );
    }
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color = Colors.white70;

    switch (message.status) {
      case AppConstants.statusRead:
        icon = Icons.done_all;
        color = Colors.lightBlueAccent;
        break;
      case AppConstants.statusDelivered:
        icon = Icons.done_all;
        color = Colors.white70;
        break;
      case AppConstants.statusSent:
      default:
        icon = Icons.done;
        color = Colors.white70;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }
}
