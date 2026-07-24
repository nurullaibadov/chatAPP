import 'package:flutter/material.dart';
import '../../../data/models/message_model.dart';

class MessageActionsSheet extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Function(String emoji) onReactionSelected;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDeleteForSelf;
  final VoidCallback onDeleteForEveryone;

  const MessageActionsSheet({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReactionSelected,
    required this.onReply,
    required this.onEdit,
    required this.onDeleteForSelf,
    required this.onDeleteForEveryone,
  });

  @override
  Widget build(BuildContext context) {
    final emojis = ['❤️', '👍', '😂', '😮', '😢', '🔥'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onReactionSelected(emoji);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                onReply();
              },
            ),
            if (isMe && message.type == 'text' && !message.isDeletedForEveryone)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete for me'),
              onTap: () {
                Navigator.pop(context);
                onDeleteForSelf();
              },
            ),
            if (isMe && !message.isDeletedForEveryone)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete for everyone',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteForEveryone();
                },
              ),
          ],
        ),
      ),
    );
  }
}
